require 'object_digest'
require 'addressable/uri'
require 'say_when/storage/active_record_strategy'

class Feed < ActiveRecord::Base
  include Announce::Publisher

  acts_as_scheduled
  acts_as_paranoid

  has_many :responses, class_name: 'FeedResponse'
  has_many :entries, class_name: 'FeedEntry'

  serialize :options, JSON
  serialize :categories, JSON
  serialize :keywords, JSON

  serialize :owners, JSON
  serialize :author, JSON
  serialize :web_master, JSON
  serialize :managing_editor, JSON

  after_create :schedule_sync
  after_commit :feed_updated

  after_commit :feed_created, on: :create
  after_commit :feed_updated, on: :update
  before_destroy :feed_deleted

  def feed_created
    announce_entry(:create)
  end

  def feed_updated
    announce_entry(:update)
  end

  def feed_deleted
    announce_entry(:delete)
  end

  def announce_entry(action)
    entry = Api::FeedRepresenter.new(self).to_json
    announce(:feed, action, entry)
  end

  def schedule_sync
    scheduled_jobs.clear
    schedule_cron('0 0/10 * * * ?', scheduled: self, job_method: 'sync')
  end

  def sync(options = nil)
    options = {} if options.nil?
    return false unless response = updated_response(options[:force])

    with_lock do
      feed = Feedjira::Feed.parse(response.body)
      update_feed!(feed)
      keepers = feed.entries.map { |e| insert_or_update_entry(e).id }
      entries.where('id not in (?)', keepers).each { |e| e.destroy }
    end
    true
  end

  def parse_categories(feed)
    icat = Array(feed.itunes_categories).map(&:strip).select{|c| !c.blank?}
    mcat = Array(feed.media_categories)
    rcat = Array(feed.categories)
    (icat + mcat + rcat).compact.uniq
  end

  def parse_keywords(feed)
    ikey = Array(feed.itunes_keywords).map(&:strip)
    mkey = Array(feed.media_keywords).map(&:strip)
    (ikey + mkey).compact.uniq
  end

  def update_feed!(feed)
    %w( copyright description feedburner_name generator language last_built
      last_modified pub_date published title ttl
      update_frequency update_period url web_master
    ).each do |at|
      self.try("#{at}=", feed.try(at))
    end

    { itunes_explicit: :explicit, itunes_image: :image_url,
      itunes_subtitle: :subtitle, itunes_summary: :summary,
      itunes_new_feed_url: :new_feed_url
    }.each do |k,v|
      self.try("#{v}=", feed.try(k))
    end

    self.web_master = feed.web_master ? Person.new(feed.web_master) : nil
    self.managing_editor = feed.managing_editor ? Person.new(feed.managing_editor) : nil
    self.author = feed.itunes_author ? Person.new(feed.itunes_author) : nil
    self.owners = Array(feed.itunes_owners).map { |o| Person.new(name: o.name, email: o.email) }

    self.block = (feed.itunes_block == 'yes')
    self.categories = parse_categories(feed)
    self.complete = (feed.itunes_complete == 'yes')
    self.copyright ||= feed.media_copyright
    self.hub_url = Array(feed.hubs).first
    self.keywords = parse_keywords(feed)
    self.thumb_url = feed.image.try(:url)

    save!
  end

  def insert_or_update_entry(entry)
    if current = find_entry(entry)
      current.update_with_entry!(entry)
    else
      current = FeedEntry.create_with_entry!(self, entry)
    end
    current
  end

  def find_entry(entry)
    if !entry.entry_id.blank?
      entries.with_deleted.where(entry_id: entry.entry_id)
    elsif !entry.url.blank?
      entries.with_deleted.where(url: entry.url)
    else
      entries.with_deleted.where(digest: FeedEntry.entry_digest(entry))
    end.first
  end

  def updated_response(force = false)
    response = nil

    last_response = last_successful_response

    response = if (force || last_response.nil?)
      retrieve
    elsif !last_response.fresh?
      validate_response(last_response)
    end

    response
  end

  def retrieve
    http_response = connection.get(uri.path, uri.query_values)
    response = FeedResponse.for_response(http_response)
    self.responses << response

    response
  end

  def validate_response(last_response)
    http_response = feed_http_response(last_response)
    feed_response = FeedResponse.for_response(http_response)

    if feed_response.not_modified?
      feed_response = nil
    else
      self.responses << feed_response
    end

    feed_response
  end

  def feed_http_response(last_response = nil)
    http_response = connection.get do |req|
      req.url uri.path, uri.query_values
      req.headers['If-Modified-Since'] = last_response.last_modified if last_response.try(:last_modified)
      req.headers['If-None-Match']     = last_response.etag if last_response.try(:etag)
    end

    http_response
  end

  def uri
    @uri ||= Addressable::URI.parse(feed_url)
  end

  def connection
    conn_uri = "#{uri.scheme}://#{uri.host}:#{uri.port}"
    client ||= Faraday.new(conn_uri) { |stack| stack.adapter :excon }.tap do |c|
      c.headers[:user_agent] = "PRX Crier FeedValidator/#{ENV['CRIER_VERSION']}"
    end
  end

  def last_successful_response
    responses.where(url: feed_url, status: '200').order(created_at: :desc).first
  end
end

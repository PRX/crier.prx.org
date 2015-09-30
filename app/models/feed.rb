require 'object_digest'
require 'addressable/uri'

class Feed < ActiveRecord::Base
  has_many :responses, class_name: 'FeedResponse'
  has_many :entries, class_name: 'FeedEntry'

  serialize :options, JSON
  serialize :categories, JSON
  serialize :keywords, JSON
  serialize :owners, JSON

  after_commit :feed_updated

  def feed_updated
  end

  def sync(force=false)
    return unless response = updated_response(force)

    feed = Feedjira::Feed.parse(response.body)
    update_feed(feed)

    feed.entries.each do |entry|
      insert_or_update_entry(entry)
    end
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

  def update_feed(feed)
    %w( copyright description feedburner_name generator language last_built
      last_modified managing_editor pub_date published title ttl
      update_frequency update_period url web_master
    ).each do |at|
      self.try("#{at}=", feed.try(at))
    end

    { itunes_author: :author, itunes_image: :image_url,
      itunes_subtitle: :subtitle, itunes_summary: :summary,
      itunes_new_feed_url: :new_feed_url
    }.each do |k,v|
      self.try("#{v}=", feed.try(k))
    end

    self.block      = (feed.itunes_block == 'yes')
    self.categories = parse_categories(feed)
    self.complete   = (feed.itunes_complete == 'yes')
    self.copyright  ||= feed.media_copyright
    self.explicit   = (feed.itunes_explicit && feed.itunes_explicit != 'no')
    self.hub_url    = Array(feed.hubs).first
    self.thumb_url  = feed.image.try(:url)
    self.keywords   = parse_keywords(feed)
    self.owners     = (feed.itunes_owners || []).collect { |o|
      { name: o.name, email: o.email }
    }

    save!
  end

  def insert_or_update_entry(entry)
    if current = find_entry(entry)
      current.update_with_entry(entry)
    else
      FeedEntry.create_with_entry(self, entry)
    end
  end

  def find_entry(entry)
    if !entry.entry_id.blank?
      entries.where(entry_id: entry.entry_id)
    elsif !entry.url.blank?
      entries.where(url: entry.url)
    else
      entries.where(digest: FeedEntry.entry_digest(entry))
    end.first
  end

  def updated_response(force=false)
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

  def feed_http_response(last_response=nil)
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
    client = Faraday.new("#{uri.scheme}://#{uri.host}:#{uri.port}") {|stack| stack.adapter :excon }
  end

  def last_successful_response
    responses.where(url: feed_url, status: '200').order(created_at: :desc).first
  end
end

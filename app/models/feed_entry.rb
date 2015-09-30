class FeedEntry < ActiveRecord::Base
  include Announce::Publisher

  acts_as_paranoid

  belongs_to :feed

  serialize :categories, JSON
  serialize :keywords, JSON

  after_commit :feed_entry_created, on: :create
  after_commit :feed_entry_updated, on: :update
  before_destroy :feed_entry_deleted

  def feed_entry_created
    announce_entry(:create)
  end

  def feed_entry_updated
    announce_entry(:update)
  end

  def feed_entry_deleted
    announce_entry(:delete)
  end

  def announce_entry(action)
    entry = FeedEntryRepresenter.new(self).to_json
    announce(:feed_entry, action, entry)
  end

  def self.create_with_entry(feed, entry)
    entry = new.update_feed_entry(entry)
    entry.feed = feed
    entry.save
  end

  def self.entry_digest(entry)
    entry.to_h.to_digest.to_s
  end

  def is_changed?(entry)
    digest != FeedEntry.entry_digest(entry)
  end

  def update_with_entry(entry)
    return unless is_changed?(entry)
    update_feed_entry(entry)
    save
  end

  def update_feed_entry(entry)
    self.digest = FeedEntry.entry_digest(entry)

    %w( categories comment_count comment_rss_url comment_url content description
      entry_id feedburner_orig_enclosure_link feedburner_orig_link published
      title updated url
    ).each do |at|
      self.try("#{at}=", entry[at.to_sym])
    end

    { itunes_explicit: :explicit, itunes_image: :image_url,
      itunes_order: :position, itunes_subtitle: :subtitle,
      itunes_summary: :summary
    }.each do |k,v|
      self.try("#{v}=", entry[k])
    end

    self.author              = entry[:itunes_author] || entry[:author] || entry[:creator]
    self.block               = (entry[:itunes_block] == 'yes')
    self.duration            = seconds_for_duration(entry[:itunes_duration] || entry[:duration])
    self.is_closed_captioned = (entry[:itunes_is_closed_captioned] == 'yes')
    self.keywords            = (entry[:itunes_keywords] || '').split(',').map(&:strip)

    # TODO: do something with media_groups/media_contents if no enclosure
    if entry[:enclosure]
      self.enclosure_length = entry[:enclosure].length
      self.enclosure_type   = entry[:enclosure].type
      self.enclosure_url    = entry[:enclosure].url
    end

    self
  end

  def seconds_for_duration(duration)
    duration.split(':').reverse.inject([0,0]) do |info, i|
      sum = (i.to_i * 60**info[0]) + info[1]
      [(info[0]+1), sum]
    end[1]
  end
end

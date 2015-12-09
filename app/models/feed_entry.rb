class FeedEntry < ActiveRecord::Base
  include Announce::Publisher

  acts_as_paranoid

  belongs_to :feed
  has_many :contents, -> { order("position ASC") }, dependent: :destroy
  has_one :enclosure

  serialize :categories, JSON
  serialize :keywords, JSON
  serialize :author, JSON

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
    new.update_attributes_with_entry(entry).tap do |fe|
      fe.feed = feed
      fe.save
    end
  end

  def self.entry_digest(entry)
    entry.to_h.to_digest.to_s
  end

  def is_changed?(entry)
    digest != FeedEntry.entry_digest(entry)
  end

  def update_with_entry(entry)
    restore if deleted?
    if is_changed?(entry)
      update_attributes_with_entry(entry)
      save
    end
  end

  def update_attributes_with_entry(entry)
    self.digest = FeedEntry.entry_digest(entry)

    %w( categories comment_count comment_rss_url comment_url content description
      entry_id feedburner_orig_enclosure_link feedburner_orig_link is_perma_link
      published title updated url
    ).each do |at|
      self.try("#{at}=", entry[at])
    end

    { itunes_explicit: :explicit, itunes_image: :image_url,
      itunes_order: :position, itunes_subtitle: :subtitle,
      itunes_summary: :summary
    }.each do |k,v|
      self.try("#{v}=", entry[k])
    end

    self.block               = (entry[:itunes_block] == 'yes')
    self.duration            = seconds_for_duration(entry[:itunes_duration] || entry[:duration])
    self.is_closed_captioned = (entry[:itunes_is_closed_captioned] == 'yes')
    self.keywords            = (entry[:itunes_keywords] || '').split(',').map(&:strip)

    author_attr = entry[:itunes_author] || entry[:author] || entry[:creator]
    self.author = Person.new(author_attr) if author_attr

    update_enclosure(entry)
    update_contents(entry)

    self
  end

  def update_enclosure(entry)
    if !entry[:enclosure] || (enclosure && enclosure.url != entry[:enclosure].url)
      self.enclosure.destroy if enclosure
      self.enclosure = nil
    end
    if entry[:enclosure]
      self.enclosure ||= Enclosure.build_from_enclosure(self, entry[:enclosure])
    end
    enclosure
  end

  def update_contents(entry)
    if entry[:media_contents].blank?
      self.contents.clear
    else
      entry[:media_contents].each_with_index do |c, i|
        existing_content = contents[i]
        if existing_content && existing_content.url != c.url
          existing_content.destroy
          existing_content = nil
        end
        if !existing_content
          new_content = Content.build_from_content(self, c)
          contents << new_content
          new_content.set_list_position(i + 1)
        end
      end
      if entry[:media_contents].size < contents.size
        self.contents = contents[0, entry[:media_contents].size]
      end
    end
  end

  def seconds_for_duration(duration)
    (duration  || '').split(':').reverse.inject([0,0]) do |info, i|
      sum = (i.to_i * 60**info[0]) + info[1]
      [(info[0]+1), sum]
    end[1]
  end
end

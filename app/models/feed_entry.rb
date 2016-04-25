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

  def self.create_with_entry!(feed, entry)
    new.tap do |fe|
      fe.feed = feed
      fe.update_attributes_with_entry!(entry)
    end
  end

  def self.entry_digest(entry)
    entry.to_h.to_digest.to_s
  end

  def is_changed?(entry)
    digest != FeedEntry.entry_digest(entry)
  end

  def update_with_entry!(entry)
    restore if deleted?
    if is_changed?(entry)
      with_lock do
        update_attributes_with_entry!(entry)
      end
    end
  end

  def update_attributes_with_entry!(entry)
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
    save!
    self
  end

  def update_enclosure(entry)
    enclosures_differ = enclosure && enclosure.differs_from?(entry[:enclosure])
    if enclosures_differ
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
      contents.destroy_all
    else
      to_insert = []
      to_destroy = []

      if contents.size > entry[:media_contents].size
        to_destroy = contents[entry[:media_contents].size..(contents.size - 1)]
      end

      entry[:media_contents].each_with_index do |c, i|
        existing_content = self.contents[i]
        if existing_content
          if existing_content.url == c.url
            existing_content.update_with_content!(c)
          else
            to_destroy << existing_content
            existing_content = nil
          end
        end
        if !existing_content
          new_content = Content.build_from_content(self, c)
          new_content.position = i + 1
          to_insert << new_content
        end
      end
      self.contents.destroy(to_destroy)
      to_insert.each{|c| contents << c}
    end
  end

  def seconds_for_duration(duration)
    (duration  || '').split(':').reverse.inject([0,0]) do |info, i|
      sum = (i.to_i * 60**info[0]) + info[1]
      [(info[0]+1), sum]
    end[1]
  end
end

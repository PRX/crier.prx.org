class FeedEntryRepresenter < BaseRepresenter
  link :self do
    feed_entry_url represented.feed, represented
  end

  link 'prx:feed' do
    {
      href: feed_url(represented.feed),
      title: represented.feed.title
    } if represented.feed
  end

  property :entry_id, as: :guid

  property :url
  property :feedburner_orig_link
  property :image_url

  property :author

  property :title
  property :subtitle
  property :content
  property :summary
  property :description

  property :enclosure_length
  property :enclosure_type
  property :enclosure_url
  property :feedburner_orig_enclosure_link
  property :duration

  property :explicit
  property :keywords
  property :categories
  property :is_closed_captioned
  property :position
  property :block

  property :comment_url
  property :comment_rss_url
  property :comment_count

  property :published
  property :updated
end

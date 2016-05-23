class Api::FeedEntryRepresenter < Api::BaseRepresenter
  def self_url(entry)
    api_entry_path(entry)
  end

  link :feed do
    {
      href: api_feed_path(represented.feed),
      title: represented.feed.title
    } if represented.feed
  end
  embed :feed, class: Feed, decorator: Api::FeedRepresenter

  property :entry_id, as: :guid
  property :is_perma_link

  property :url
  property :feedburner_orig_link
  property :image_url

  property :author

  property :title
  property :subtitle
  property :content
  property :summary
  property :description

  property :enclosure, class: Enclosure, decorator: Api::EnclosureRepresenter
  property :feedburner_orig_enclosure_link
  property :duration

  property :explicit
  property :is_closed_captioned
  property :position
  property :block

  property :comment_url
  property :comment_rss_url
  property :comment_count

  property :published
  property :updated

  collection :contents, class: Content, decorator: Api::ContentRepresenter
  collection :keywords
  collection :categories
end

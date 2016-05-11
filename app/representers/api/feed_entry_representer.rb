class Api::FeedEntryRepresenter < Api::BaseRepresenter

  link :feed do
    {
      href: api_feed_path(represented.feed),
      title: represented.feed.name
    } if represented.feed
  end
  embed :feed, class: Feed, decorator: FeedRepresenter

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

  property :enclosure, class: Enclosure, decorator: EnclosureRepresenter
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

  collection :contents, class: Content, decorator: ContentRepresenter
  collection :keywords
  collection :categories
end

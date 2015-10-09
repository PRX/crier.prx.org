class FeedEntryRepresenter < BaseRepresenter

  curies do
    [{
      name: :prx,
      href: "http://#{prx_meta_host}/relation/{rel}",
      templated: true
    }]
  end

  link :self do
    api_feed_entry_path represented.feed, represented
  end

  link 'prx:feed' do
    {
      href: api_feed_path(represented.feed),
      title: represented.feed.title
    } if represented.feed
  end
  embed :feed, as: 'prx:feed', class: Feed, decorator: FeedRepresenter

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

  property :enclosure_length
  property :enclosure_type
  property :enclosure_url
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

  collection :keywords
  collection :categories
end

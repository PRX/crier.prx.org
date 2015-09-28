class FeedRepresenter < BaseRepresenter
  link :self do
    api_feed_url represented
  end

  link 'prx:entries' do
    api_feed_entries_url represented
  end

  property :feed_url
  property :new_feed_url
  property :url
  property :image_url
  property :thumb_url
  property :hub_url

  property :title
  property :subtitle
  property :description
  property :summary

  property :owners
  property :author
  property :managing_editor
  property :web_master

  property :keywords
  property :categories
  property :explicit
  property :language
  property :copyright

  property :generator
  property :ttl
  property :complete
  property :update_period
  property :update_frequency
  property :feedburner_name
  property :block

  property :published
  property :last_built
  property :last_modified
  property :pub_date
end

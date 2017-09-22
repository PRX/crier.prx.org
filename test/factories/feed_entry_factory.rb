FactoryGirl.define do
  factory :feed_entry do
    feed
    entry_id 'thisisnotarealentryid'
    url "http://thisisnotarealurl.com/entry"
  end
end

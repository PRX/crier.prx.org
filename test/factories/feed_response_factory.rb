FactoryGirl.define do
  factory :feed_response do
    feed
    url 'http://feeds.99percentinvisible.org/99percentinvisible'
    status 200
  end
end

require 'test_helper'

describe SyncFeedJob do

  before {
    stub_request(:get, "http://feeds.99percentinvisible.org/99percentinvisible").
      to_return(status: 200, body: test_file('/fixtures/99percentinvisible.xml'), headers: {})
  }

  let(:feed) { Feed.create!(feed_url: 'http://feeds.99percentinvisible.org/99percentinvisible') }

  it 'sync feed by id' do
    SyncFeedJob.new.perform(feed.id)
  end
end

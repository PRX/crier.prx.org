require 'test_helper'

describe SyncFeedJob do

  before {
    stub_request(:get, "http://feeds.99percentinvisible.org/99percentinvisible").
      to_return(status: 200, body: test_file('/fixtures/99percentinvisible.xml'), headers: {})
    stub_request(:head, /http:\/\/.*\.podtrac.com\/.*/).
      to_return(status: 200, body: '', headers: { etag: '1234' })
  }
  let(:feed) { Feed.create!(feed_url: 'http://feeds.99percentinvisible.org/99percentinvisible') }

  it 'sync feed by id' do
    SyncFeedJob.new.perform(feed, true)
  end

  it 'does not schedule jobs if unschedule false' do
    SyncFeedJob.new.perform(feed, false)
  end

  it 'does not schedule jobs with a deleted feed' do
    feed.stub(:deleted?, true) do
      SyncFeedJob.new.perform(feed, true)
    end
  end
end

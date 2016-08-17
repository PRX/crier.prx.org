require 'test_helper'

describe SyncFeedJob do

  before {
    stub_request(:get, "http://feeds.99percentinvisible.org/99percentinvisible").
      to_return(status: 200, body: test_file('/fixtures/99percentinvisible.xml'), headers: {})
    stub_head_requests(/http:\/\/.*\.podtrac.com\/.*/)
  }
  let(:job) { SyncFeedJob.new }
  let(:feed) do
    f = Feed.create!(feed_url: 'http://feeds.99percentinvisible.org/99percentinvisible')
    clear_enqueued_jobs # clear the initial sync
    f
  end

  it 'syncs and reschedules feeds' do
    assert_enqueued_jobs 0
    feed.responses.count.must_equal 0
    job.perform(feed, true)
    assert_enqueued_jobs 1
    feed.responses.count.must_equal 1
  end

  it 'does not sync or reschedule deleted feeds' do
    feed.destroy!
    assert_enqueued_jobs 0
    feed.responses.count.must_equal 0
    job.perform(feed, true)
    assert_enqueued_jobs 0
    feed.responses.count.must_equal 0
  end

  it 'does not schedule jobs if unschedule false' do
    assert_enqueued_jobs 0
    feed.responses.count.must_equal 0
    job.perform(feed, false)
    assert_enqueued_jobs 0
    feed.responses.count.must_equal 1
  end

  it 'does not reschedule jobs that throw an error' do
    raises_exception = -> { raise ArgumentError.new }
    feed.stub(:sync, raises_exception) do
      assert_enqueued_jobs 0
      feed.responses.count.must_equal 0
      begin
        job.perform(feed, true)
        raise 'should not have gotten here'
      rescue ArgumentError => e
        assert_enqueued_jobs 0
        feed.responses.count.must_equal 0
      end
    end
  end

end

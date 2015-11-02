require 'test_helper'
require 'ping'

describe Ping do

  let(:ping) { Ping.new }

  let(:feed) { Feed.create!(feed_url: 'http://feeds.99percentinvisible.org/99percentinvisible', url: 'http://99percentinvisible.org') }

  describe 'xml rpc' do
    it 'handles rack requests' do
      Ping.call('weblogUpdates.ping').must_equal([405, {}, ["Method Not Allowed"]])
    end
  end

  describe 'ping methods' do
    before(:each) {
      feed
      clear_enqueued_jobs
    }

    it 'can accept ping for an existing feed' do
      ping.ping('99percentinvisible', feed.feed_url)[:flerror].must_equal false
      assert_enqueued_jobs 1
      ping.ping('99percentinvisible', feed.url)[:flerror].must_equal false
      assert_enqueued_jobs 2
    end

    it 'returns error for nonexist feed ping' do
      ping.ping('thisisnotapodcast', 'http://nowayjose.com/thepodcast')[:flerror].must_equal true
      assert_enqueued_jobs 0
    end

    it 'can accept extended ping for an existing feed' do
      ping.extendedPing('99percentinvisible', feed.url, nil, feed.feed_url, nil)[:flerror].must_equal false
      assert_enqueued_jobs 1
    end

    it 'errors for extended ping of a nonexistant feed' do
      ping.extendedPing('99percentinvisible', 'meh', nil, 'blegh', nil)[:flerror].must_equal true
      assert_enqueued_jobs 0
    end
  end
end

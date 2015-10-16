require 'test_helper'

describe FeedEntry do

  let(:feed_entry) { create(:feed_entry) }
  let(:feed) { feed_entry.feed }

  it 'announces changes' do
    feed_entry.stub(:announce, true) do
      feed_entry.announce_entry(:create)
    end
  end

  it 'can be created from an rss entry' do
    rss_feed = Feedjira::Feed.parse(test_file('/fixtures/99percentinvisible.xml'))
    rss_feed_entry = rss_feed.entries.first
    entry = FeedEntry.create_with_entry(feed, rss_feed_entry)
    entry.entry_id.must_equal 'http://99percentinvisible.prx.org/?p=807'
    entry.title.must_equal '132- Castle on the Park'
    entry.explicit.must_equal 'no'
    entry.duration.must_equal 1126
    entry.enclosure['url'].must_equal 'http://www.podtrac.com/pts/redirect.mp3/media.blubrry.com/99percentinvisible/cdn.99percentinvisible.org/wp-content/uploads/132-Castle-on-the-Park.mp3'
  end

  it 'calculates a digest from an rss entry' do
    FeedEntry.entry_digest({foo: 'bar'}).must_equal 'w6uP8Tcg6K2QR905Rms8iXTlksL6OD1KOWBxTK7wxPI='
    FeedEntry.entry_digest({foo: 'bar1'}).wont_equal 'w6uP8Tcg6K2QR905Rms8iXTlksL6OD1KOWBxTK7wxPI='
  end

  it 'checks if the entry is changed' do
    FeedEntry.stub(:entry_digest, 'abc') do
      feed_entry.digest = 'abc'
      feed_entry.is_changed?('foo').must_equal false
      feed_entry.digest = 'def'
      feed_entry.is_changed?('foo').must_equal true
    end
  end

  it 'updates from a changed rss entry' do
    rss_entry = Minitest::Mock.new
    rss_entry.expect(:to_h, {foo: 'bar'})
    feed_entry.stub(:update_attributes_with_entry, true) do
      feed_entry.update_with_entry(rss_entry)
    end
  end

end

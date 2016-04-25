require 'test_helper'

describe FeedEntry do

  let(:feed_entry) { create(:feed_entry) }
  let(:feed) { feed_entry.feed }

  before {
    stub_request(:head, /http:\/\/.*\.podtrac.com\/.*/).
      to_return(status: 200, body: '', headers: { etag: '1234' })
  }

  it 'announces changes' do
    feed_entry.stub(:announce, true) do
      feed_entry.announce_entry(:create)
    end
  end

  it 'can be created from an rss entry' do
    rss_feed = Feedjira::Feed.parse(test_file('/fixtures/99percentinvisible.xml'))
    rss_feed_entry = rss_feed.entries.first
    entry = FeedEntry.create_with_entry!(feed, rss_feed_entry)
    entry.entry_id.must_equal 'http://99percentinvisible.prx.org/?p=807'
    entry.title.must_equal '132- Castle on the Park'
    entry.explicit.must_equal 'no'
    entry.duration.must_equal 1126
    entry.enclosure.url.must_equal 'http://www.podtrac.com/pts/redirect.mp3/media.blubrry.com/99percentinvisible/cdn.99percentinvisible.org/wp-content/uploads/132-Castle-on-the-Park.mp3'
  end

  it 'can be created from an rss entry with no audio or duration' do
    rss_feed = Feedjira::Feed.parse(test_file('/fixtures/serial_no_audio.xml'))
    rss_feed_entry = rss_feed.entries.first
    entry = FeedEntry.create_with_entry!(feed, rss_feed_entry)
    entry.must_be :valid?
    entry.duration.must_equal 0
  end

  it 'can be created from an rss entry with media content' do
    rss_feed = Feedjira::Feed.parse(test_file('/fixtures/serialpodcast.xml'))
    rss_feed_entry = rss_feed.entries.first
    entry = FeedEntry.create_with_entry!(feed, rss_feed_entry)
    entry.contents.size.must_equal 2
    entry.contents.first.position.must_equal 1
    entry.contents.last.position.must_equal 2
  end

  it 'can be updated from an rss entry with media content' do
    rss_feed = Feedjira::Feed.parse(test_file('/fixtures/serialpodcast.xml'))
    rss_feed_entry = rss_feed.entries.first
    entry = FeedEntry.create_with_entry!(feed, rss_feed_entry)
    entry.contents.size.must_equal 2
    entry.contents.first.position.must_equal 1
    entry.contents.last.position.must_equal 2
    l = entry.contents.last

    rss_feed_entry.title = rss_feed_entry.title + " changed"
    entry.update_with_entry!(rss_feed_entry)
    entry.contents.size.must_equal 2
    entry.contents.first.position.must_equal 1
    entry.contents.last.position.must_equal 2
    entry.contents.last.must_equal l
  end

  it 'calculates a digest from an rss entry' do
    FeedEntry.entry_digest({foo: 'bar'}).must_equal 'O6iQfnolIydIjfOQ7VF8Rblt6tAzYAIZvcpxB9HT+Io='
    FeedEntry.entry_digest({foo: 'bar1'}).wont_equal 'O6iQfnolIydIjfOQ7VF8Rblt6tAzYAIZvcpxB9HT+Io='
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
    feed_entry.stub(:update_attributes_with_entry!, true) do
      feed_entry.update_with_entry!(rss_entry)
    end
  end

  it 'handles update of enclosure url' do
    rss_feed = Feedjira::Feed.parse(test_file('/fixtures/serialpodcast.xml'))
    rss_feed_entry = rss_feed.entries.first
    entry = FeedEntry.create_with_entry!(feed, rss_feed_entry)
    enc = entry.enclosure

    # no enclosure created for the same entry
    entry.update_enclosure(rss_feed_entry).must_equal enc

    # new enclosure created
    rss_feed_entry[:enclosure].url = "http://dts.podtrac.com/redirect.mp3/files.serialpodcast.org/sites/default/files/podcast/1445350094/serial-s01-e12_UPDATED.mp3"
    new_enc = entry.update_enclosure(rss_feed_entry)
    new_enc.wont_be_nil
    new_enc.wont_equal enc
  end

  it 'handles update of enclosure mp3 ETag header' do
    rss_feed = Feedjira::Feed.parse(test_file('/fixtures/serialpodcast.xml'))
    rss_feed_entry = rss_feed.entries.first
    entry = FeedEntry.create_with_entry!(feed, rss_feed_entry)
    enc = entry.enclosure

    # no enclosure created for the same entry
    entry.update_enclosure(rss_feed_entry).must_equal enc

    stub_request(:head, /http:\/\/.*\.podtrac.com\/.*/).
      to_return(:status => 200, :body => "", :headers => { etag: '5678' })

    # new enclosure created
    new_enc = entry.update_enclosure(rss_feed_entry)
    new_enc.wont_be_nil
    new_enc.wont_equal enc
  end

  it 'handles update contents count' do
    rss_feed_4c = Feedjira::Feed.parse(test_file('/fixtures/serialpodcast_4contents.xml'))
    rss_feed_entry_4c = rss_feed_4c.entries.first
    entry = FeedEntry.create_with_entry!(feed, rss_feed_entry_4c)
    entry.contents.size.must_equal 4

    rss_feed = Feedjira::Feed.parse(test_file('/fixtures/serialpodcast.xml'))
    rss_feed_entry = rss_feed.entries.first
    entry.update_contents(rss_feed_entry)
    entry.contents(true).size.must_equal 2
  end
end

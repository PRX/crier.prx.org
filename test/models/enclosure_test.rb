require 'test_helper'

describe Enclosure do

  let(:feed_entry) { build(:feed_entry) }
  let(:enclosure) { Enclosure.new(url: 'u', file_size: 10, mime_type: 'mt') }
  let(:rss_enclosure) {
    rss_feed = Feedjira::Feed.parse(test_file('/fixtures/serialpodcast.xml'))
    rss_feed_entry = rss_feed.entries.first
    rss_feed_entry.enclosure
  }

  it 'can be constructed from feed enclosure' do
    e = Enclosure.build_from_enclosure(feed_entry, rss_enclosure)
    e.url.must_equal 'http://dts.podtrac.com/redirect.mp3/files.serialpodcast.org/sites/default/files/podcast/1445350094/serial-s01-e12.mp3'
    e.file_size.must_equal 27485957
    e.mime_type.must_equal 'audio/mpeg'
  end

  it 'can be updated' do
    enclosure.update_with_enclosure(rss_enclosure)
    enclosure.url.must_equal 'http://dts.podtrac.com/redirect.mp3/files.serialpodcast.org/sites/default/files/podcast/1445350094/serial-s01-e12.mp3'
    enclosure.file_size.must_equal 27485957
    enclosure.mime_type.must_equal 'audio/mpeg'
  end
end

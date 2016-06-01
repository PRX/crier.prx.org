require 'test_helper'

describe Content do

  let(:feed_entry) { create(:feed_entry) }
  let(:content) { Content.create(url: 'u', file_size: 10, mime_type: 'mt') }
  let(:rss_content) {
    rss_feed = Feedjira::Feed.parse(test_file('/fixtures/serialpodcast.xml'))
    rss_feed_entry = rss_feed.entries.first
    rss_feed_entry[:media_contents].first
  }

  before {
    stub_head_requests(/https:\/\/.*\.amazonaws.com\/.*/)
  }

  it 'can be constructed from feed content' do
    c = Content.build_from_content(feed_entry, rss_content)
    c.is_default.wont_equal true
    c.bitrate.must_equal 64
    c.channels.must_equal 1
    c.duration.must_equal 3252.19
    c.expression.must_equal "sample"
    c.file_size.must_equal 26017749
    c.lang.must_equal "en"
    c.medium.must_equal "audio"
    c.samplingrate.must_equal 44.1
    c.mime_type.must_equal "audio/mpeg"
    c.url.must_equal "https://s3.amazonaws.com/prx-dovetail/testserial/serial_audio.mp3"
  end

  it 'can be updated' do
    content.update_with_content!(rss_content)
    content.url.must_equal "https://s3.amazonaws.com/prx-dovetail/testserial/serial_audio.mp3"
    content.file_size.must_equal 26017749
    content.mime_type.must_equal 'audio/mpeg'
  end
end

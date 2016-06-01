require 'test_helper'

describe MediaResource do

  before {
    stub_request(:head, "https://s3.amazonaws.com/prx-dovetail/testserial/serial_audio.mp3").
      to_return(status: 200, body: "", headers: { 'Etag' => '12345' } )
  }

  let(:media_resource) { MediaResource.create(url: 'https://s3.amazonaws.com/prx-dovetail/testserial/serial_audio.mp3', file_size: 10, mime_type: 'mt') }

  let(:rss_content) {
    rss_feed = Feedjira::Feed.parse(test_file('/fixtures/serialpodcast.xml'))
    rss_feed_entry = rss_feed.entries.first
    rss_feed_entry[:media_contents].first
  }

  it 'can check to see if changed based on url' do
    media_resource.wont_be :is_changed?, rss_content
    media_resource.url = "http://changed.com/changed.mp3"
    media_resource.must_be :is_changed?, rss_content
  end

  it 'can check to see if changed based on etag' do
    media_resource.etag = "12345"
    media_resource.wont_be :is_changed?, rss_content
    media_resource.etag = "54321"
    media_resource.must_be :is_changed?, rss_content
  end
end

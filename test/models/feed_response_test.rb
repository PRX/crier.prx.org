require 'test_helper'

describe FeedResponse do

  let(:feed_response) { create(:feed_response) }
  let(:feed) { feed_response.feed }

  it 'can handle banged up last modified dates' do
    feed_response.httpdate('Thu, 19 May 2016 16:04:14 GMT').wont_be_nil
    feed_response.httpdate('').must_be_nil
    feed_response.httpdate('GMT').must_be_nil
  end

  it 'can delete older responses for a feed' do
    responses = []
    4.times { responses << FeedResponse.create!(feed_id: feed.id, status: '200') }
    responses.size.must_equal 4
    feed.responses(true).count.must_equal 5

    feed_response.delete_old_responses

    feed.responses.count.must_equal 3
  end

  it 'can fix the max age for a response' do
    feed_response.response_headers = { 'Age' => 10, 'Cache-Control' => 'private, max-age=20'}
    feed_response.fix_max_age
    feed_response.headers['Cache-Control'].must_equal 'private, max-age=10'
  end
end

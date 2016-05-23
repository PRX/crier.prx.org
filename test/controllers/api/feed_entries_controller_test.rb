require 'test_helper'

describe Api::FeedEntriesController do
  let(:feed_entry) { create(:feed_entry) }
  let(:feed) { feed_entry.feed }

  it 'should show' do
    get(:show, { api_version: 'v1', format: 'json', id: feed_entry.id } )
    assert_response :success
  end

  it 'should list' do
    feed_entry.id.wont_be_nil
    get(:index, { api_version: 'v1', format: 'json' } )
    assert_response :success
  end

  it 'should list for feed' do
    feed_entry.id.wont_be_nil
    feed.id.wont_be_nil
    get(:index, { api_version: 'v1', format: 'json', feed_id: feed.id } )
    assert_response :success
  end
end

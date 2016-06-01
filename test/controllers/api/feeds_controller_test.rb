require 'test_helper'

describe Api::FeedsController do
  let(:feed) { create(:feed) }

  it 'should show' do
    get(:show, { api_version: 'v1', format: 'json', id: feed.id } )
    assert_response :success
  end

  it 'should list' do
    feed.id.wont_be_nil
    get(:index, { api_version: 'v1', format: 'json' } )
    assert_response :success
  end
end

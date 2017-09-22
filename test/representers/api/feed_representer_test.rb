# encoding: utf-8

require 'test_helper'
require 'feed' if !defined?(Feed)

describe Api::FeedRepresenter do

  let(:feed) { create(:feed) }
  let(:representer) { Api::FeedRepresenter.new(feed) }
  let(:json) { JSON.parse(representer.to_json) }

  it 'includes attributes in json' do
    json['feedUrl'].must_equal feed.feed_url
  end
end

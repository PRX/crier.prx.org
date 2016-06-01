# encoding: utf-8

require 'test_helper'
require 'feed_entry' if !defined?(FeedEntry)

describe Api::FeedEntryRepresenter do

  let(:feed_entry) { create(:feed_entry) }
  let(:representer) { Api::FeedEntryRepresenter.new(feed_entry) }
  let(:json) { JSON.parse(representer.to_json) }

  it 'includes attributes in json' do
    json['guid'].must_equal feed_entry.entry_id
    json['url'].must_equal feed_entry.url
  end
end

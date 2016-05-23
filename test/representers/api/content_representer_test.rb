# encoding: utf-8

require 'test_helper'
require 'content' if !defined?(Content)

describe Api::ContentRepresenter do

  let(:content) { create(:content) }
  let(:representer) { Api::ContentRepresenter.new(content) }
  let(:json) { JSON.parse(representer.to_json) }

  it 'includes attributes in json' do
    json['url'].must_equal content.url
  end
end

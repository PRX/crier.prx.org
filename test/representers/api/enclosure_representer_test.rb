# encoding: utf-8

require 'test_helper'
require 'enclosure' if !defined?(Enclosure)

describe Api::EnclosureRepresenter do

  let(:enclosure) { create(:enclosure) }
  let(:representer) { Api::EnclosureRepresenter.new(enclosure) }
  let(:json) { JSON.parse(representer.to_json) }

  it 'includes attributes in json' do
    json['url'].must_equal enclosure.url
  end
end

require 'test_helper'

describe Enclosure do

  let(:enclosure) { Enclosure.new(url: 'u', length: 0, type: 't') }

  it 'can be constructed by a hash' do
    e = Enclosure.new(url: 'u', length: 0, type: 't')
    e.url.must_equal 'u'
    e.length.must_equal 0
    e.type.must_equal 't'
  end

  it 'can be constructed from an object' do
    e = Enclosure.new(enclosure)
    e.url.must_equal 'u'
    e.length.must_equal 0
    e.type.must_equal 't'
  end

  it 'can turn into a hash' do
    e = enclosure.as_json
    e[:url].must_equal 'u'
    e[:length].must_equal 0
    e[:type].must_equal 't'
  end
end

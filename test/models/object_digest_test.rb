require 'test_helper'
require 'object_digest'

describe 'ObjectDigest' do

  let (:raw_feed) { test_file('/fixtures/serialpodcast.xml') }

  it 'digests hash' do
    { b: 1, a: 2 }.as_digest.must_equal "a=2,b=1"
    { 'a' => '2', 'b' => 1 }.as_digest.must_equal "a=2,b=1"
  end

  it 'digests numeric' do
    1.as_digest.must_equal "1"
  end

  it 'digests string' do
    "1".as_digest.must_equal "1"
  end

  it 'digests array' do
    [1,'b','3'].as_digest.must_equal "1,b,3"
  end

  it 'digests entries the same for the same feed data' do
    entry = Feedjira::Feed.parse(raw_feed).entries.first
    entry2 = Feedjira::Feed.parse(raw_feed).entries.first
    entry.as_digest.must_match /^creator=Dana,description=On January 13/
    entry.as_digest.must_equal entry2.as_digest
  end
end

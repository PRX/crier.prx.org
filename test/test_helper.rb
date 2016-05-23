ENV['RAILS_ENV'] = 'test'

require 'simplecov'
SimpleCov.start 'rails'

if ENV['TRAVIS']
  require 'coveralls'
  Coveralls.wear!
end

def use_webmock?
  ENV['PMP_IMPORTER_WEBMOCK'].nil? || (ENV['PMP_IMPORTER_WEBMOCK'] == 'true')
end

ENV['RAILS_ENV'] ||= 'test'

require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'factory_girl'
require 'minitest/reporters'
require 'minitest/autorun'
require 'minitest/spec'
require 'minitest/pride'
require 'webmock/minitest'
require 'announce'
require 'announce/testing'
require 'active_job/test_helper'

WebMock.allow_net_connect! unless use_webmock?

class ActiveSupport::TestCase
  include FactoryGirl::Syntax::Methods
  include Announce::Testing
  include ActiveJob::TestHelper
end

class MiniTest::Spec
  include FactoryGirl::Syntax::Methods
  include Announce::Testing
  include ActiveJob::TestHelper
end

def json_file(name)
  test_file("/fixtures/#{name}.json")
end

def test_file(path)
  File.read( File.dirname(__FILE__) + path)
end

def stub_head_requests(url_regex)
  stub_request(:head, url_regex).
    to_return(status: 200, body: '', headers: {})
end

include Announce::Testing
reset_announce

TestObject = Struct.new(:title, :is_root_resource) do
  extend ActiveModel::Naming
  def persisted?; false; end
  def to_model; self; end
  def to_param; '1'; end
  def id; 1; end
  def id=(_id); _id; end
end

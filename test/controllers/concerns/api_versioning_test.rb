# encoding: utf-8
require 'api_versioning'

describe ApiVersioning do

  class ApiVersioningTestController < ActionController::Base
    include ApiVersioning
  end

  let (:controller) { ApiVersioningTestController.new }

  before {
    ApiVersioningTestController.api_versions(:v0)
  }

  it 'allows known api versions' do
    ApiVersioningTestController.understood_api_versions.must_equal ['v0']
  end

  it 'raises error for unknown api versions' do
    avtc = ApiVersioningTestController.new
    avtc.params = {api_version: "v1000"}
    avtc.response = ActionDispatch::Response.new
    avtc.check_api_version

    avtc.response.status.must_equal 406
  end
end

require 'test_helper'

describe CacheControl do

  let(:cache_control) { CacheControl.new('private, max-age=0, no-cache, no-store, s-maxage=0, must-revalidate, proxy-revalidate') }

  it 'checks attributes' do
    cache_control.wont_be :public?
    cache_control.must_be :private?
    cache_control.must_be :no_store?
    cache_control.must_be :no_cache?
    cache_control.must_be :must_revalidate?
    cache_control.must_be :proxy_revalidate?
  end

  it 'gives max age' do
    cache_control.max_age.must_equal 0
    cache_control.shared_max_age.must_equal 0
  end

  it 'normalize_max_ages(age)' do
    cache_control.normalize_max_ages(10)
    cache_control.max_age.must_equal -10
    cache_control.shared_max_age.must_equal -10
  end
end

require 'roar/decorator'

class BaseRepresenter < Roar::Decorator
  include Roar::JSON::HAL

  curies do
    [{
      name: :prx,
      href: "http://#{prx_meta_host}/relation/{rel}",
      templated: true
    }]
  end

  def prx_meta_host
    (ENV['META_HOST'] || 'meta.prx.org')
  end
end

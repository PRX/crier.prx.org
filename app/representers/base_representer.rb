require 'roar/decorator'

class BaseRepresenter < Roar::Decorator
  include Roar::JSON::HAL

  def prx_meta_host
    (ENV['META_HOST'] || 'meta.prx.org')
  end

  def self.embed(name, options={})
    options[:embedded] = true
    options[:writeable] = false
    options[:if] ||= ->(_a) { id } unless options[:zoom] == :always

    property(name, options)
  end

  def self.embeds(name, options={})
    options[:embedded] = true
    options[:writeable] = false
    options[:if] ||= ->(_a) { id } unless options[:zoom] == :always

    collection(name, options)
  end
end

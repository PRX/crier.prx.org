class Enclosure
  attr_accessor :length, :type, :url

  def initialize(arg)
    if arg.is_a?(Hash)
      self.length = arg[:length].to_i
      self.type = arg[:type]
      self.url = arg[:url]
    elsif arg.respond_to?(:length)
      self.length = arg.length.to_i
      self.type = arg.type
      self.url = arg.url
    end
  end

  def as_json(*args)
    {
      length: length,
      type: type,
      url: url
    }
  end
end

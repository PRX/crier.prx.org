class Person
  attr_accessor :name, :email

  def initialize(arg)
    if arg.is_a?(Hash)
      self.email = arg[:email]
      self.name = arg[:name]
    else
      s = arg.to_s.try(:strip)
      if match = s.match(/(.+) \((.+)\)/)
        self.email = match[1]
        self.name = match[2]
      else
        self.name = s
      end
    end
  end

  def as_json(*args)
    {
      name: name,
      email: email
    }
  end
end

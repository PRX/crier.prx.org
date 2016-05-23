class Api::EnclosureRepresenter < Roar::Decorator
  include Roar::JSON::HAL

  property :url
  property :mime_type, as: :type
  property :file_size, as: :length
end

class EnclosureRepresenter < BaseRepresenter
  property :url
  property :mime_type, as: :type
  property :file_size, as: :length
end

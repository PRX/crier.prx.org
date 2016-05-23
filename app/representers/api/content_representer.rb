class Api::ContentRepresenter < Roar::Decorator
  include Roar::JSON::HAL

  property :position
  property :url
  property :mime_type, as: :type
  property :file_size
  property :is_default
  property :medium
  property :expression
  property :bitrate
  property :framerate
  property :samplingrate
  property :channels
  property :duration
  property :height
  property :width
  property :lang
end

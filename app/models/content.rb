class Content < MediaResource

  def self.build_from_content(entry, content)
    new.update_attributes_with_content(content)
    new.tap do |c|
      c.feed_entry = entry
      c.update_attributes_with_content(content)
    end
  end

  def update_with_content!(content)
    update_attributes_with_content(content)
    save!
  end

  def update_attributes_with_content(content)
    %w( url medium expression bitrate framerate samplingrate
      channels duration height width lang
    ).each do |at|
      self.try("#{at}=", content.send(at))
    end

    self.mime_type    = content.type
    self.file_size    = content.file_size.to_i
    self.is_default   = content.is_default && content.is_default.downcase == 'true'
    self.etag         = get_media_etag(content.url)
    self
  end
end

# url should specify the direct URL to the media object. If not included, a <media:player> element must be specified.
# fileSize is the number of bytes of the media object. It is an optional attribute.
# type is the standard MIME type of the object. It is an optional attribute.
# medium is the type of object (image | audio | video | document | executable). While this attribute can at times seem redundant if type is supplied, it is included because it simplifies decision making on the reader side, as well as flushes out any ambiguities between MIME type and object type. It is an optional attribute.
# isDefault determines if this is the default object that should be used for the <media:group>. There should only be one default object per <media:group>. It is an optional attribute.
# expression determines if the object is a sample or the full version of the object, or even if it is a continuous stream (sample | full | nonstop). Default value is "full". It is an optional attribute.
# bitrate is the kilobits per second rate of media. It is an optional attribute.
# framerate is the number of frames per second for the media object. It is an optional attribute.
# samplingrate is the number of samples per second taken to create the media object. It is expressed in thousands of samples per second (kHz). It is an optional attribute.
# channels is number of audio channels in the media object. It is an optional attribute.
# duration is the number of seconds the media object plays. It is an optional attribute.
# height is the height of the media object. It is an optional attribute.
# width is the width of the media object. It is an optional attribute.
# lang is the primary language encapsulated in the media object. Language codes possible are detailed in RFC 3066. This attribute is used similar to the xml:lang attribute detailed in the XML 1.0 Specification (Third Edition). It is an optional attribute.

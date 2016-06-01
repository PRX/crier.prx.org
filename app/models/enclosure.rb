class Enclosure < MediaResource
  def self.build_from_enclosure(entry, enclosure)
    new.tap do |e|
      e.feed_entry = entry
      e.update_attributes_with_enclosure(enclosure)
    end
  end

  def update_with_enclosure(enclosure)
    update_attributes_with_enclosure(enclosure)
    save
  end

  def update_attributes_with_enclosure(enclosure)
    self.file_size = enclosure.length.to_i
    self.mime_type = enclosure.type
    self.url       = enclosure.url
    self.etag      = get_media_etag(enclosure.url)
    self
  end
end

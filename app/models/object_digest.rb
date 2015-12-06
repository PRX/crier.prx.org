require 'digest/md5'

class Object
  def as_digest
    [:to_h, :as_json, :instance_values].each do |m|
      return send(m).as_digest if respond_to?(m)
    end
    to_s
  end

  def to_digest
    Digest::SHA256.base64digest(as_digest)
  end
end

class Numeric
  def as_digest
    to_s
  end
end

class String
  def as_digest
    self
  end
end

class Array
  def as_digest
    map(&:as_digest).join(',')
  end
end

class Hash
  def as_digest
    sort.map{|e| e.map(&:as_digest).join('=') }.join(',')
  end
end

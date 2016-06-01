class MediaResource < ActiveRecord::Base
  belongs_to :feed_entry

  def get_media_etag(url)
    # Send a HEAD request following redirects to the enclosure URL.
    # Note that there may not be an etag header, which is OK.
    conn = Faraday.new(url) do |client|
      client.headers[:user_agent] = "PRX Crier FeedValidator/#{ENV['CRIER_VERSION']}"
      client.use FaradayMiddleware::FollowRedirects, limit: 5
      client.adapter :excon
    end

    etag = nil
    begin
      head_response = conn.head
      if head_response.headers
        etag = head_response[:etag]
      end
    rescue FaradayMiddleware::RedirectLimitReached
      etag = nil
    end

    etag = nil if etag.blank?
    etag
  end

  # This intentionally does not check if the etag changes when none is saved
  def is_changed?(media)
    media && ((url != media.url) || (etag && (etag != get_media_etag(media.url))))
  end
end

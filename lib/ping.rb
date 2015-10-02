require 'xmlrpc'
require 'xmlrpc/rack_server'

class Ping
  def self.call(env)
    server = XMLRPC::RackServer.new
    server.add_introspection
    server.add_handler('weblogUpdates', self.new)
    server.call(env)
  end

  def ping(title, url)
    feed = Feed.find_by_feed_url(url)

    if feed
      SyncFeedJob.perform_later(feed.id)
      { flerror: false, message: 'Ok'}
    else
      { flerror: true, message: 'Unknown feed'}
    end
  end
end

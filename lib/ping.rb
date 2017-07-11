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
    ping_feed(url, url)
  end

  def extendedPing(title, url, changed_url, feed_url, tags)
    ping_feed(url, feed_url)
  end

  def ping_feed(url, feed_url)
    if feed = Feed.find_by_url(url) || Feed.find_by_feed_url(feed_url)
      sync_feed(feed)
      { flerror: false, message: 'Ok' }
    else
      { flerror: true, message: 'Feed not found' }
    end
  end

  def sync_feed(feed)
    feed.sync(force: true)
  end
end

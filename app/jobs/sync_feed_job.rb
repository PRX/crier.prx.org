class SyncFeedJob < ActiveJob::Base

  queue_as :crier_default

  def perform(feed_id)
    ActiveRecord::Base.connection_pool.with_connection do
      Feed.find(feed_id).sync
    end
  end
end

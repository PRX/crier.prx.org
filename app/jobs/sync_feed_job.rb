class SyncFeedJob < ActiveJob::Base

  queue_as :crier_default

  def perform(feed, reschedule = false)
    ActiveRecord::Base.connection_pool.with_connection do
      begin
        if feed.nil? || feed.deleted?
          reschedule = false
        else
          feed.sync
        end
      ensure
        if reschedule && feed
          SyncFeedJob.set(wait: feed.sync_interval).perform_later(feed, true)
        end
      end
    end
  end
end

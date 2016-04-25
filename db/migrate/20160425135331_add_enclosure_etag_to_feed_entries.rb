class AddEnclosureEtagToFeedEntries < ActiveRecord::Migration
  def change
    add_column :feed_entries, :enclosure_etag, :string
  end
end

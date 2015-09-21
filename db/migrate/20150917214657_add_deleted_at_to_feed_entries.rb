class AddDeletedAtToFeedEntries < ActiveRecord::Migration
  def change
    add_column :feed_entries, :deleted_at, :datetime
    add_index :feed_entries, :deleted_at
  end
end

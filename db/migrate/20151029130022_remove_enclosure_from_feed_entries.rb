class RemoveEnclosureFromFeedEntries < ActiveRecord::Migration
  def change
    remove_column :feed_entries, :enclosure, :text
  end
end

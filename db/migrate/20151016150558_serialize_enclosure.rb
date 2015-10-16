class SerializeEnclosure < ActiveRecord::Migration
  def change
    add_column :feed_entries, :enclosure, :text
    remove_column :feed_entries, :enclosure_length
    remove_column :feed_entries, :enclosure_type
    remove_column :feed_entries, :enclosure_url
  end
end

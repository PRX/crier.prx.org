class AddIsPermaLink < ActiveRecord::Migration
  def change
    add_column :feed_entries, :is_perma_link, :boolean
  end
end

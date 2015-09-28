class AddThumbUrlToFeed < ActiveRecord::Migration
  def change
    add_column :feeds, :thumb_url, :string
  end
end

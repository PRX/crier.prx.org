class AddEtagToMediaResource < ActiveRecord::Migration
  def change
    add_column :media_resources, :etag, :string
  end
end

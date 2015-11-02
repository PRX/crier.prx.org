class AddPositionToMediaResource < ActiveRecord::Migration
  def change
    add_column :media_resources, :position, :integer
  end
end

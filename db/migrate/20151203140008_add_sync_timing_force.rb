class AddSyncTimingForce < ActiveRecord::Migration
  def change
    add_column :feeds, :always_retrieve, :boolean
    add_column :feeds, :retrieve_delay, :integer
  end
end

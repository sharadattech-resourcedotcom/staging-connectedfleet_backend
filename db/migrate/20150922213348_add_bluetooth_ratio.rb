class AddBluetoothRatio < ActiveRecord::Migration
  def change
  	add_column :trip_stats, :bt_ratio, :integer, :default => 0
  end
end

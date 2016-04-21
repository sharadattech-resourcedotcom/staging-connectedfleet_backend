class AddDongleToPoints < ActiveRecord::Migration
  def change
  	add_column :points, :vehicle_speed, :float, :default => -1
  end
end

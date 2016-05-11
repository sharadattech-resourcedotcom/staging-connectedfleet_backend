class AddFuelData < ActiveRecord::Migration
  def change
  	add_column :points, :fuel_economy, :float, :default => -1
  end
end

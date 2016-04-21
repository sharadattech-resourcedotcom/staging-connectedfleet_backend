class AddColsToPOints < ActiveRecord::Migration
  def change
  	add_column :points, :bt, :integer, :default => -1
  	add_column :points, :dongle, :integer, :default => -1
  	add_column :points, :rpm, :integer, :default => -1
  	add_column :points, :fuel_pressure, :integer, :default => -1
  end
end

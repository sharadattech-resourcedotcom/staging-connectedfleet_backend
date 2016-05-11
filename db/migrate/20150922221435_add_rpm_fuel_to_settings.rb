class AddRpmFuelToSettings < ActiveRecord::Migration
  def change
  	add_column :settings, :rpm_points, :float, :default => 0
  	add_column :settings, :rpm_limit, :integer, :default => 0
  	add_column :settings, :fuel_points, :float, :default => 0
  	add_column :settings, :fuel_limit, :integer, :default => 0
  	add_column :trip_stats, :behaviour_points, :float, :default => 0
  	add_column :points, :behaviour_points, :float, :default => 0
  end
end

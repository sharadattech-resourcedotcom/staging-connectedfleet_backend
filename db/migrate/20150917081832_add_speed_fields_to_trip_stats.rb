class AddSpeedFieldsToTripStats < ActiveRecord::Migration
  def change
  	add_column :trip_stats, :speed_max, :integer
  	add_column :trip_stats, :speed_min, :integer
  	add_column :trip_stats, :speed_avg, :integer
  end
end

class AddDongleStatsCols < ActiveRecord::Migration
  def change
  	add_column :trip_stats, :rpm_avg, :float, :default => -1
  	add_column :trip_stats, :fuel_avg, :float, :default => -1
  end
end

class AddFieldsToTripStats < ActiveRecord::Migration
  def change
  	add_column :trip_stats, :speeds_over_123, :integer 
  	add_column :trip_stats, :speeds_over_123_long, :integer
  end
end

class RemoveStartEndLocationFromTrips < ActiveRecord::Migration
  def change
    remove_column :trips, :start_location
    remove_column :trips, :end_location
  end
end

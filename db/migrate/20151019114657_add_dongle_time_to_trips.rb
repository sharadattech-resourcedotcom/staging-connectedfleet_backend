class AddDongleTimeToTrips < ActiveRecord::Migration
  def change
  	add_column :trips, :dongle_time, :integer
  end
end

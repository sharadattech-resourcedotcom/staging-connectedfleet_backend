class AddPrivateAndBusinessMileageToTrips < ActiveRecord::Migration
  def change
  	add_column :trips, :private_mileage, :integer, :default => 0
  end
end

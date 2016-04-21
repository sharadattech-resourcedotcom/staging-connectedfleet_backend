class AddVehicleIdToTrips < ActiveRecord::Migration
  def change
  	add_column :trips, :vehicle_id, :integer
  	add_foreign_key(:trips, :vehicles, column: 'vehicle_id')
  end
end

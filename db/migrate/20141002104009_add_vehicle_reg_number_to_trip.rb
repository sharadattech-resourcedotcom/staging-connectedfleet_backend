class AddVehicleRegNumberToTrip < ActiveRecord::Migration
  def change
     add_column :trips, :vehicle_reg_number, :string
  end
end

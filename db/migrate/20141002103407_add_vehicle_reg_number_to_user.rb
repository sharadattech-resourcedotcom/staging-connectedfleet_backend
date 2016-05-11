class AddVehicleRegNumberToUser < ActiveRecord::Migration
  def change
     add_column :users, :vehicle_reg_number, :string
  end
end

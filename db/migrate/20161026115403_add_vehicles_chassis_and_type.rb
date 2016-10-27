class AddVehiclesChassisAndType < ActiveRecord::Migration
  def change
  	add_column :vehicles, :chassis_no, :string
  	add_column :vehicles, :vehicle_type, :string
  end
end

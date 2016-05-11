class AddVehicleIdToMobileInspections < ActiveRecord::Migration
  def change
  	add_column :mobile_inspections, :vehicle_id, :integer
  	add_foreign_key(:mobile_inspections, :vehicles, column: 'vehicle_id')
  end
end

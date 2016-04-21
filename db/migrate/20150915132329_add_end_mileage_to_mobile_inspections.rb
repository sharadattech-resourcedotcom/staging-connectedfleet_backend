class AddEndMileageToMobileInspections < ActiveRecord::Migration
  def change
  	add_column :mobile_inspections, :mileage, :integer
  end
end

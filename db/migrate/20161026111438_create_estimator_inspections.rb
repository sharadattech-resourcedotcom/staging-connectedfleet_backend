class CreateEstimatorInspections < ActiveRecord::Migration
  def change
    create_table :estimator_inspections do |t|
    	t.belongs_to :driver, :class_name => "User"
    	t.belongs_to :vehicle
    	t.string :vehicle_type
    	t.json :check_list
    	t.string :chassis_no
    	t.integer :mileage
    	t.string :color
    	t.timestamps
    end
  end
end

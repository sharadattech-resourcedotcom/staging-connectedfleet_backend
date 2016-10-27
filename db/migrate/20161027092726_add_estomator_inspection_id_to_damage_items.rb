class AddEstomatorInspectionIdToDamageItems < ActiveRecord::Migration
  def change
  	add_reference :damage_items, :estimator_inspection, :null => true
  	add_foreign_key(:damage_items, :estimator_inspections, column: 'estimator_inspection_id')
  end
end

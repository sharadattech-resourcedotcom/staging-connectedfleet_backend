class AddEstimatorInspectionDamageCollectionsForeignKey < ActiveRecord::Migration
  def change
  	add_foreign_key(:damage_collections, :estimator_inspections, column: 'estimator_inspection_id')
  end
end

class AddDamageCollectionsRepairMethodAndPrice < ActiveRecord::Migration
  def change
  	add_column :damage_collections, :repair_method, :string
  	add_column :damage_collections, :repair_price, :integer
  	change_column :damage_collections, :mobile_inspection_id, :integer, :null => true
  	add_reference :damage_collections, :estimator_inspection, :null => true
  end
end

class CreateDamageCollections < ActiveRecord::Migration
  def change
    create_table :damage_collections do |t|
    	t.belongs_to :mobile_inspection, :null => false
    	t.timestamps
    	t.column :collection_id, :integer
    	t.column :collection_type, :string
    	t.column :x_percent, :float
    	t.column :y_percent, :float
    	t.column :description, :text
    	t.column :dual_tyres, :boolean
    	t.column :spare, :integer
		t.column :driver_back, :integer
		t.column :passenger_back, :integer
		t.column :driver_front, :integer
		t.column :passenger_front, :integer
    end
    add_column :damage_items, :collection_id, :integer, :null => true
    add_foreign_key(:damage_collections, :mobile_inspections, column: 'mobile_inspection_id')
  end
end

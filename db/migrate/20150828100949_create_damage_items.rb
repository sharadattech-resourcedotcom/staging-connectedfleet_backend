class CreateDamageItems < ActiveRecord::Migration
  def change
    create_table :damage_items do |t|
    	t.belongs_to :mobile_inspection
    	t.belongs_to :user 
    	t.column :description, :string
    	t.column :file_path, :string
    	t.column :local_id, :integer
    end
    add_foreign_key(:damage_items, :mobile_inspections, column: 'mobile_inspection_id')
    add_foreign_key(:damage_items, :users, column: 'user_id')
  end
end

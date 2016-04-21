class AddInspectionDatetimeToDamageItems < ActiveRecord::Migration
  def change
  	add_column :damage_items, :inspection_datetime, :datetime
  end
end

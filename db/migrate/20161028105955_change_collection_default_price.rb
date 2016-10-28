class ChangeCollectionDefaultPrice < ActiveRecord::Migration
  def change
  	change_column :damage_collections, :repair_price, :integer, :null => false, :default => 0
  end
end

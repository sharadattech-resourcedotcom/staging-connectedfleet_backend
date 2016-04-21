class ChangeInspectionsAndDamages < ActiveRecord::Migration
  def change
  	change_column :damage_items, :description, :text 
  end
end

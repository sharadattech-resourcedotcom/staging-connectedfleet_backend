class AddIsSentToMobileInspections < ActiveRecord::Migration
  def change
  	add_column :mobile_inspections, :is_sent, :boolean, :default => false
  end
end

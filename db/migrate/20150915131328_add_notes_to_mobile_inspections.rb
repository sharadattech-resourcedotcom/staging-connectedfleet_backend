class AddNotesToMobileInspections < ActiveRecord::Migration
  def change
  	add_column :mobile_inspections, :notes, :text
  end
end

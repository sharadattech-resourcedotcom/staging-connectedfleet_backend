class AddFieldsToInspection < ActiveRecord::Migration
  def change
  	add_column :mobile_inspections, :ref_number, :string
  	add_column :mobile_inspections, :job_type, :string
  end
end

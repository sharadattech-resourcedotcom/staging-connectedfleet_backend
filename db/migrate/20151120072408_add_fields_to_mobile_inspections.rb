class AddFieldsToMobileInspections < ActiveRecord::Migration
  def change
  	add_column :mobile_inspections, :customer_email, :string
  	add_column :mobile_inspections, :postcode, :string
  	add_column :mobile_inspections, :city, :string
  	add_column :mobile_inspections, :address_line_1, :string
  	add_column :mobile_inspections,	:address_line_2, :string
  	add_column :mobile_inspections,	:home_number, :string
  end
end

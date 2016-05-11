class AddCustomerNameToMobileInspections < ActiveRecord::Migration
  def change
  	add_column :mobile_inspections, :customer_name, :string
  end
end

class AddCompanyToManufacturers < ActiveRecord::Migration
  def change
  	add_column :manufacturers, :company_id, :integer, :null => true
  end
end

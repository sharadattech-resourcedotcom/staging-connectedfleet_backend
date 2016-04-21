class AddCompanyIdToManufacturer < ActiveRecord::Migration
  def change
  	add_foreign_key(:manufacturers, :companies, column: 'company_id')
  end
end

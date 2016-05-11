class AddCompanyToManufac < ActiveRecord::Migration
  def change
  	add_foreign_key(:vehicles, :manufacturers, column: 'manufacturer_id')
  end
end

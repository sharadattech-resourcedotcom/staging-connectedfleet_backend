class AddForeignToManagerD < ActiveRecord::Migration
  def change
    add_foreign_key(:manager_drivers, :users, column: 'manager_id')
    add_foreign_key(:manager_drivers, :users, column: 'driver_id')
  end
end
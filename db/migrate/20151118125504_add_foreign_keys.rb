class AddForeignKeys < ActiveRecord::Migration
  def change
  	add_foreign_key(:payrolls, :users, column: 'user_id')
  	add_foreign_key(:users, :driver_types, column: 'driver_type_id')

  end
end

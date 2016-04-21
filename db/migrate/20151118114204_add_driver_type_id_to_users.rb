class AddDriverTypeIdToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :driver_type_id, :integer
  end
end

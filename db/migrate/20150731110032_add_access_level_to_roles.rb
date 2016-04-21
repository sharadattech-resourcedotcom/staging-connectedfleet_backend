class AddAccessLevelToRoles < ActiveRecord::Migration
  def change
  	add_column :roles, :access_level, :integer
  end
end

class CreateUserPermissions < ActiveRecord::Migration
  def change
    create_table :user_permissions do |t|
    	t.belongs_to :user
    	t.belongs_to :permission
    end
  end
end

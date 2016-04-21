class CreatePermissions < ActiveRecord::Migration
  def change
    create_table :permissions do |t|
    	t.column :description, :string
    end
  end
end

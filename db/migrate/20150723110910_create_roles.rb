class CreateRoles < ActiveRecord::Migration
  def change
    create_table :roles do |t|
    	t.column :description, :string
    end
  end
end

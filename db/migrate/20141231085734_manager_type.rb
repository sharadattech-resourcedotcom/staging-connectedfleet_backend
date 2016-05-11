class ManagerType < ActiveRecord::Migration
  def change
    add_column :users, :manager_type, :string
  end
end

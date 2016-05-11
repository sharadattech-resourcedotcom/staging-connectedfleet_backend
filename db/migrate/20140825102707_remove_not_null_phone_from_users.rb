class RemoveNotNullPhoneFromUsers < ActiveRecord::Migration
  def change
    change_column :users, :phone, :string, :limit => 25, :null => true
  end
end

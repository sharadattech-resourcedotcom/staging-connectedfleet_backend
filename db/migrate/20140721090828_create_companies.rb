class CreateCompanies < ActiveRecord::Migration
  def change
    create_table :companies do |t|
      t.text :name, :null => false
      t.text :address, :null => false
      t.string :phone, :null => false, :limit => 25
      t.string :login, :null => false, :limit => 55, :unique => true
      t.string :password, :null => false, :limit => 128
      t.string :salt, :null => false, :limit => 50
      t.column :last_login, :timestamp
    end
  end
end

class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.integer :user_type, :null => false
      t.text   :first_name, :null => false
      t.text   :last_name, :null => false
      t.string :phone, :limit => 25,  :null => false
      t.string :email, :limit => 50, :null => false, :unique => true
      t.string :password, :limit => 128, :null => false
      t.string :salt, :limit => 50, :null => false
      t.column :last_login, :timestamp
      t.boolean :on_trip, :null => false
      t.belongs_to :company, :null => false
    end
  end
end

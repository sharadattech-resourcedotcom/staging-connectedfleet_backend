class CreateTokens < ActiveRecord::Migration
  def change
    create_table :tokens do |t|
      t.string :access, :limit => 36, :null => false
      t.string :refresh, :limit => 36, :null => false
      t.column :timestamp, :timestamp, :null => false
      t.column :lifetime, :interval, :null => false
      t.belongs_to :user, :null => false
      t.belongs_to :device
    end
  end
end

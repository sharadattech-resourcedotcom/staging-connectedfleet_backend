class CreatePoints < ActiveRecord::Migration
  def change
    create_table :points, :id => false do |t|
      t.column :timestamp, :timestamp, :null =>false
      t.column :latitude, :real, :null =>false
      t.column :longitude, :real, :null =>false
      t.boolean :on_pause
      t.belongs_to :trip
      t.belongs_to :user, :null =>false
    end
    execute "ALTER TABLE points ADD PRIMARY KEY (timestamp, user_id);"
  end
end
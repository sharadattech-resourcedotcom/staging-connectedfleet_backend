class CreateTrips < ActiveRecord::Migration
  def change
    create_table :trips do |t|
      t.column :estimated_time, :interval, :null => false
      t.text :start_location, :null => false
      t.text :end_location
      t.column :start_date, :timestamp, :null => false
      t.column :end_date, :timestamp
      t.column :start_lat, :real, :null => false
      t.column :start_lon, :real, :null => false
      t.column :end_lat, :real
      t.column :end_lon, :real
      t.integer :start_mileage
      t.integer :end_mileage
      t.text :reason
      t.string :status, :limit => 10,  :null => false
      t.belongs_to :user, :null => false
      t.column :period_start_date, :timestamp
    end
  end
end
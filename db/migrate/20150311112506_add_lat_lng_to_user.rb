class AddLatLngToUser < ActiveRecord::Migration
  def change
  	add_column :users, :lat, :float, :default => 0
  	add_column :users, :lng, :float, :default => 0
  	add_column :users, :last_sync, :datetime, :null => true
  end
end

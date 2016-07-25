class AddHoursRangeToDriverType < ActiveRecord::Migration
  def change
  	add_column :driver_types, :normal_start, :integer, :default => 7, :null => false
  	add_column :driver_types, :normal_end, :integer, :default => 19, :null => false
  end
end

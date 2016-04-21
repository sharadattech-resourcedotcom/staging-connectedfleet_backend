class AddStartEndLocation < ActiveRecord::Migration
  def change
    add_column :trips, :start_location, :string, :null => true
    add_column :trips, :end_location, :string, :null => true
  end
end

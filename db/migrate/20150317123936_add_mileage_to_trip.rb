class AddMileageToTrip < ActiveRecord::Migration
  def change
  	add_column :trips, :mileage, :integer, :default => 0
  end
end

class AddTripIdIndexToPoints < ActiveRecord::Migration
  def change
    add_index :points, :trip_id
  end
end

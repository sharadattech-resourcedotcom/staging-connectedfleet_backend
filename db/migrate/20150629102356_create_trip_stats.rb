class CreateTripStats < ActiveRecord::Migration
  def change
    create_table :trip_stats do |t|
    	 t.column :trip_id, :integer
    	 t.column :points_total, :integer
    	 t.column :dongle_points, :integer
    	 t.column :ratio, :float
    	 t.belongs_to :trip, :null => false     
    end
  end
end

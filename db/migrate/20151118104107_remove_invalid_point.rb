class RemoveInvalidPoint < ActiveRecord::Migration
  def change
  	points = Point.where("DATE(timestamp) > '2015-09-30'  AND((vehicle_speed > 0 AND rpm < 0) OR (rpm > 0 AND vehicle_speed < 0) OR ((rpm < 0 OR vehicle_speed < 0) AND fuel_economy > 0))")
  	puts points.length
  	points.destroy_all
  end
end

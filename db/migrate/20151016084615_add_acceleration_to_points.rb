class AddAccelerationToPoints < ActiveRecord::Migration
  def change
  	add_column :points, :acceleration, :float, :default => -1
  	add_column :trip_stats, :acc_avg, :float, :default => -1
  end
end

class AddStatsGenToTrips < ActiveRecord::Migration
  def change
  	add_column :trips, :stats_gen, :boolean, :default => false
  end
end

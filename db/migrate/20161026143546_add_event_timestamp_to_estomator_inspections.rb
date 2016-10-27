class AddEventTimestampToEstomatorInspections < ActiveRecord::Migration
  def change
  	add_column :estimator_inspections, :event_timestamp, :timestamp
  end
end

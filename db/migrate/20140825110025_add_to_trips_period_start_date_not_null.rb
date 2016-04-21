class AddToTripsPeriodStartDateNotNull < ActiveRecord::Migration
  def change
    change_column :trips, :period_start_date, :timestamp, :null => false
  end
end

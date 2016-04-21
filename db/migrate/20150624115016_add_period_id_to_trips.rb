class AddPeriodIdToTrips < ActiveRecord::Migration
  def change
    add_column :trips, :period_id, :integer
  end
end

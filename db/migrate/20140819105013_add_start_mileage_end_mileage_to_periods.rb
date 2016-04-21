class AddStartMileageEndMileageToPeriods < ActiveRecord::Migration
  def change
    add_column :periods, :start_mileage, :integer, :null => false
    add_column :periods, :end_mileage, :integer
  end
end

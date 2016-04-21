class CreateUserVehicles < ActiveRecord::Migration
  def change
    create_table :user_vehicles do |t|
    	t.belongs_to :user
    	t.belongs_to :vehicle
    end
  end
end

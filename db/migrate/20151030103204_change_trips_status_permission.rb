class ChangeTripsStatusPermission < ActiveRecord::Migration
  def change
  	permission = Permission.new
  	permission.description = "change trips status"
  	permission.save!
  end
end

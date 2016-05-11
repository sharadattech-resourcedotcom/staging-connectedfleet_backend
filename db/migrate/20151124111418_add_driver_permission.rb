class AddDriverPermission < ActiveRecord::Migration
  def change
  	permission = Permission.new
  	permission.description = "work as driver"
  	permission.save!
  	permission = Permission.new
  	permission.description = "be the manager"
  	permission.save!
  end
end

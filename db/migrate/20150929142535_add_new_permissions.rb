class AddNewPermissions < ActiveRecord::Migration
  def change
  	permission = Permission.new
  	permission.description = "approve periods"
  	permission.save!
  end
end

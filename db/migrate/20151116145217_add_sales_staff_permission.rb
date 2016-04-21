class AddSalesStaffPermission < ActiveRecord::Migration
  def change
  	permission = Permission.new
  	permission.description = "manage sales staff"
  	permission.save!
  end
end

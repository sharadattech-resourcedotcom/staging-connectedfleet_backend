class AddManageDriversTypesPermission < ActiveRecord::Migration
  def change
  	permission = Permission.new
  	permission.description = "manage drivers types"
  	permission.save!
  end
end

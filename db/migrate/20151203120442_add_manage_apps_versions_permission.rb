class AddManageAppsVersionsPermission < ActiveRecord::Migration
  def change
  	  	permission = Permission.new
  		permission.description = "manage apps versions"
  		permission.save!
  end
end

class AddMeTabPermission < ActiveRecord::Migration
  def change
  	permission = Permission.new
  	permission.description = "see me"
  	permission.save!
  end
end

class AddSecurityCodePerm < ActiveRecord::Migration
  def change
  	permission = Permission.new
  	permission.description = "generate security codes"
  	permission.save!
  end
end

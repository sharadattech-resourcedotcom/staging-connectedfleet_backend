class ChangeRolesAccessLevel < ActiveRecord::Migration
  def change
  	Role.all.each do |role|
  		case role.access_level
  			when 2
  				role.access_level = 4
  				role.save!
  			when 3
  				role.access_level = 8
  				role.save!
  			when 5
  				role.access_level = 16
  				role.save!
        when 8
          role.access_level = 16
          role.save!
  		end
  	end
  	new_role = Role.new
  	new_role.description = "Customer"
  	new_role.access_level = 1
  	new_role.save!
    rp = RolePermission.new(:role_id => new_role.id, :permission_id => Permission.where(:description => 'see vehicles list').take.id)
    rp.save!
    rp = RolePermission.new(:role_id => new_role.id, :permission_id => Permission.where(:description => 'see driver details').take.id)
    rp.save!
    rp = RolePermission.new(:role_id => new_role.id, :permission_id => Permission.where(:description => 'see vehicle details').take.id)
    rp.save!
    rp = RolePermission.new(:role_id => new_role.id, :permission_id => Permission.where(:description => 'see inspections').take.id)
    rp.save!
  end
end
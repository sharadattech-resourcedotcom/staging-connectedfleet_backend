class AddNewPermissionsToRoles < ActiveRecord::Migration
  def change
  	role = Role.where(:description => 'Driver').take
  	perms = Permission.where("description = 'work as driver'")
  	role.change_role_permissions(role.permissions + perms)
  	role = Role.where(:description => 'Line Manager').take
  	perms = Permission.where("description = 'work as driver' OR description = 'be the manager'")
  	role.change_role_permissions(role.permissions + perms)
  	role = Role.where(:description => 'Admin').take
  	perms = Permission.where("description = 'manage apps versions'")
  	role.change_role_permissions(role.permissions + perms)
  end
end

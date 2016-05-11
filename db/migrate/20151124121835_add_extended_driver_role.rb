class AddExtendedDriverRole < ActiveRecord::Migration
  def change
  		role = Role.new(:description => "Company Manager", :access_level => 8)
	  		role.save!
  		role = Role.where(:description => 'Company Manager').take
	  		rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'close period').take.id)
	  		rp.save!
			rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'see drivers list').take.id)
	  		rp.save!
			rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'see driver details').take.id)
	  		rp.save!
			rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'see driver trips list').take.id)
	  		rp.save!
			rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'update driver details').take.id)
	  		rp.save!
			rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'change driver password').take.id)
	  		rp.save!
			rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'see trips details').take.id)
	  		rp.save!
			rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'see points list').take.id)
	  		rp.save!
			rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'update trips details').take.id)
	  		rp.save!
			rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'see other users').take.id)
	  		rp.save!
			rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'create users').take.id)
	  		rp.save!
	  		rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'change period start mileage').take.id)
	  		rp.save!
	  		rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'see scheduler').take.id)
	  		rp.save!
	  		rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'approve periods').take.id)
	  		rp.save!
	  		rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'see me').take.id)
	  		rp.save!
	  		rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'work as driver').take.id)
	  		rp.save!
	  		rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'be the manager').take.id)
	  		rp.save!
	  		rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'see company trips list').take.id)
	  		rp.save!
	  		rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'see reports').take.id)
	  		rp.save!
	  		rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'see vehicles list').take.id)
	  		rp.save!
	  		rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'see vehicle details').take.id)
	  		rp.save!
	  		rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'see autoview').take.id)
	  		rp.save!
	  		rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'see appointments list').take.id)
	  		rp.save!
	  		rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'see inspections').take.id)
	  		rp.save!
  end
end

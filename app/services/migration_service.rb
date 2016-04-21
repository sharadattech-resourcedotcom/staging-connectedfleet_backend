class MigrationService
	def self.update_roles_of_photome_heads
		heads = User.eager_load(:role).where('company_id = ? AND roles.description ilike ?', 4, 'company head')
		heads.each do |u|
			u.user_permissions.delete_all
			permissions = u.role.permissions
		  	permissions.each do |permission|
		  		up = UserPermission.new(:user_id => u.id, :permission_id => permission.id)
		  		up.save!
		  	end
		end
	end
end
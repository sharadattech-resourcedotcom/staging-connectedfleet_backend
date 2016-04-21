class Role < ActiveRecord::Base
	has_many :role_permissions

    validates_presence_of :description, :access_level

	def as_json(options={})
          super((options || { }).merge({
             :methods => [:permissions]
         }))
  	end 

  	def permissions
  		role_permissions = self.role_permissions.all.eager_load(:permission)
  		permissions = []
  		role_permissions.each do |p|
  			permissions.push(p.permission)
  		end
  		return permissions
  	end

    def change_role_permissions(permissions)
        old_perms = self.role_permissions
        perms_to_remove = []
        perms_to_add = []
        users = User.all_with_role(self.description)
        old_perms.each do |rp| #Check wich permissions need to delete from users and role
            contains = false
            permissions.each do |p|
                if rp.permission_id == p[:id]
                    contains = true
                    break
                end
            end
            if contains == false
                perms_to_remove.push(rp.permission_id)
                rp.destroy!
            end
        end

        permissions.each do |p| #Check wich permissions need to add to users and role
            contains = false
            old_perms.each do |rp|
                if rp.permission_id == p[:id]
                    contains = true
                    break
                end
            end
            if contains == false
                perms_to_add.push(p[:id])
                role_permission = RolePermission.new
                role_permission.role_id = self.id
                role_permission.permission_id = p[:id]
                role_permission.save!
            end
        end   
        users.each do |u| #Add new permissions to users and delete those that are no longer in that role
            unless perms_to_add.empty?
                perms_to_add.each do |perm_id|
                    user_permission = UserPermission.new
                    user_permission.user_id = u.id
                    user_permission.permission_id = perm_id
                    user_permission.save!
                    if Permission.find(perm_id).description == 'work as driver'
                        if Period.where("user_id = ? AND status = 'opened'", u.id).empty?
                            period = Period.new
                            period.user_id = u.id
                            period.start_date = Date.today
                            period.start_mileage = 0
                            period.status = 'opened'
                            period.save!
                        end
                    end
                end
            end
            unless perms_to_remove.empty?
                perms_to_remove.each do |perm_id|
                    user_permission = UserPermission.where("user_id = ? AND permission_id = ?", u.id, perm_id).take
                    unless user_permission.nil?
                        user_permission.destroy!
                    end
                end
            end
        end
    end
end

class UsersCleanning < ActiveRecord::Migration 
	class User < ActiveRecord::Base

		has_many :trips
		has_many :points
		has_many :tokens
		has_many :devices
		has_many :periods, :class_name => 'Period', :foreign_key => 'user_id'
		has_many :mobile_logs
		belongs_to :company, :class_name => 'Company', :foreign_key => 'company_id'
		belongs_to :role, :class_name => 'Role', :foreign_key => 'role_id'
		has_many :user_permissions

		validates_presence_of :first_name, :last_name, :password, :email, :salt, :role_id, :company_id

		EMAIL_REGEX = /\A[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\z/i

		def encrypt_password(pass, salt)
		    return Digest::SHA512.hexdigest(pass + ' ' + salt)
		end

		def self.create(user, company_id)
		    salt = BCrypt::Engine.generate_salt
		    u = User.new
		    u.first_name = user[:first_name]
		    u.last_name  = user[:last_name]
		    u.phone = user[:phone]
		    u.email = user[:email]
		    u.salt  = salt
		    u.password = u.encrypt_password(user[:password], salt)
		    u.on_trip = user[:on_trip] if !user[:on_trip].nil?
		    u.company_id = company_id
		    u.role_id = user[:role_id] if !user[:role_id].nil?
		    u.role_id = Role.where(:description => user[:role_description]).take.id if user[:role_id].nil? && !user[:role_description].nil?
		    u.user_type = 1

		    raise u.errors.to_json unless u.valid?
		    if u.valid?
		        u.save
		        u.assign_permissions
		        if u.role.description == 'Driver' || u.role.description == 'Line Manager'
		            period = Period.new
		            period.user_id = u.id
		            period.start_date = Date.today
		            period.start_mileage = 0
		            period.status = 'opened'
		            period.save!
		        end
		    end
		    
		    return u
		  end

	  def self.assign_roles
	  	User.all.each do |user|
	  		case user[:user_type]
	  			when 1
	  				if user[:is_line_manager]
	  					user.update_attribute(:role_id, Role.where(:description => 'Line Manager').take.id)
	  				else
	  					user.update_attribute(:role_id, Role.where(:description => 'Driver').take.id)
	  				end
	  			when 2
	  				user.update_attribute(:role_id, Role.where(:description => 'Driver').take.id)
	  			when 4
	  				user.update_attribute(:role_id, Role.where(:description => 'Driver').take.id)
	  			when 8
	  				user.update_attribute(:role_id, Role.where(:description => 'Driver').take.id)
	  		end

	  		if user.email == 'phoadmin@clm.co.uk'
 				user.update_attribute(:role_id, Role.where(:description => 'Company Head').take.id)
	  		end
	  		user.assign_permissions unless user.role_id.nil?
	  	end
	  end

	  def assign_permissions
	  
	  	permissions = self.role.permissions
	  	permissions.each do |permission|
	  		up = UserPermission.new(:user_id => self.id, :permission_id => permission.id)
	  		up.save!
	  	end
	  end

	end

	class Company < ActiveRecord::Base
		has_many :users
		has_one :settings

		def self.create(company)
			salt = BCrypt::Engine.generate_salt

			c = Company.new
			c.name = company[:name]
			c.address  = company[:address]
			c.phone  = company[:phone]
			c.login = company[:login]
			c.salt  = salt
			c.password = c.encrypt_password(company[:password], salt)
			c.save
			User.create({first_name: c.name, last_name: 'Company', on_trip: false, email: c.login, password: company[:password], role_description: 'Admin', phone: c.phone}, c.id)
			c
		end

		def encrypt_password(pass, salt)
			return Digest::SHA512.hexdigest(pass + ' ' + salt)
		end

		def self.fill_blank_db
			Company.create({:name => '3Reign', :login => 'steve@3reign.com', :address => ' ', :phone => ' ', :password => 'steve123!!'})
		end
	end

	class Role < ActiveRecord::Base
		has_many :role_permissions

	  	def permissions

	  		role_permissions = self.role_permissions.all.eager_load(:permission)
	  		permissions = []
	  		role_permissions.each do |p|
	  			permissions.push(p.permission)
	  		end
	  		return permissions
	  	end

	  	def self.create_basic_roles
	  		r = Role.new(:description => "Driver", :access_level => 0)
	  		r.save!
	  		r = Role.new(:description => "Admin", :access_level => 5)
	  		r.save!
	  		r = Role.new(:description => 'Company Head', :access_level => 3)
	  		r.save!
	  		r = Role.new(:description => "Line Manager", :access_level => 2)
	  		r.save!
	  	end

	  	def self.assign_permissions_to_roles
	  		role = Role.where(:description => 'Driver').take
	  			rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'close period').take.id)
		  		rp.save!
		  		rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'see driver details').take.id)
		  		rp.save!
		  		rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'see driver trips list').take.id)
		  		rp.save!
		  		rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'change driver password').take.id)
		  		rp.save!
		  		rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'see trips details').take.id)
		  		rp.save!
		  		rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'see points list').take.id)
		  		rp.save!
		  	role = Role.where(:description => 'Company Head').take
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
				rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'see company trips list').take.id)
		  		rp.save!
				rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'see trips details').take.id)
		  		rp.save!
				rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'see points list').take.id)
		  		rp.save!
				rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'update trips details').take.id)
		  		rp.save!
				rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'see reports').take.id)
		  		rp.save!
				rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'see settings').take.id)
		  		rp.save!
				rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'reopen period').take.id)
		  		rp.save!
				rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'move trip').take.id)
		  		rp.save!
				rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'refresh mileage').take.id)
		  		rp.save!
				rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'see company index').take.id)
		  		rp.save!
				rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'see other users').take.id)
		  		rp.save!
				rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'grant permissions').take.id)
		  		rp.save!
				rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'create users').take.id)
		  		rp.save!
		  		rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'create trips').take.id)
		  		rp.save!
		  		rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'create vehicles').take.id)
		  		rp.save!
		  		rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'create drivers').take.id)
		  		rp.save!
		  		rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'see autoview').take.id)
		  		rp.save!
		  		rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'change period start mileage').take.id)
		  		rp.save!
		  		rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'see vehicle details').take.id)
		  		rp.save!
		  		rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'see vehicles list').take.id)
		  		rp.save!
		  		rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'update vehicles').take.id)
		  		rp.save!
		  		rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'see appointments list').take.id)
		  		rp.save!
		  		rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'create appointments').take.id)
		  		rp.save!
		  		rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'edit appointments').take.id)
		  		rp.save!
		  		rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'manage scheduler').take.id)
		  		rp.save!
		  		rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'see scheduler').take.id)
		  		rp.save!
		  		rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'see inspections').take.id)
		  		rp.save!
		  		rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'change driver manager').take.id)
		  		rp.save!
		  	role = Role.where(:description => 'Line Manager').take
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
		  		rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'see inspections').take.id)
		  		rp.save!
		  	role = Role.where(:description => 'Admin').take
		  		rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'create period').take.id)
		  		rp.save!
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
				rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'change driver password without current').take.id)
		  		rp.save!
		  		rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'create trips').take.id)
		  		rp.save!
		  		rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'create vehicles').take.id)
		  		rp.save!
				rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'see company trips list').take.id)
		  		rp.save!
				rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'see trips details').take.id)
		  		rp.save!
				rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'see points list').take.id)
		  		rp.save!
				rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'update trips details').take.id)
		  		rp.save!
				rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'see reports').take.id)
		  		rp.save!
				rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'see settings').take.id)
		  		rp.save!
				rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'reopen period').take.id)
		  		rp.save!
				rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'move trip').take.id)
		  		rp.save!
				rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'refresh mileage').take.id)
		  		rp.save!
				rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'see companies list').take.id)
		  		rp.save!
				rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'create company').take.id)
		  		rp.save!
				rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'see company index').take.id)
		  		rp.save!
				rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'see other users').take.id)
		  		rp.save!
		  		rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'change period start mileage').take.id)
		  		rp.save!
				rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'grant permissions').take.id)
		  		rp.save!
				rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'create users').take.id)
		  		rp.save!
		  		rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'create drivers').take.id)
		  		rp.save!
				rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'manage roles').take.id)
		  		rp.save!
				rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'see autoview').take.id)
		  		rp.save!
				rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'synchronize logs').take.id)
		  		rp.save!
		  		rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'see vehicle details').take.id)
		  		rp.save!
		  		rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'see vehicles list').take.id)
		  		rp.save!
		  		rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'update vehicles').take.id)
		  		rp.save!
		  		rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'see appointments list').take.id)
		  		rp.save!
		  		rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'create appointments').take.id)
		  		rp.save!
		  		rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'edit appointments').take.id)
		  		rp.save!
		  		rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'manage scheduler').take.id)
		  		rp.save!
		  		rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'see scheduler').take.id)
		  		rp.save!
		  		rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'see inspections').take.id)
		  		rp.save!
		  		rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'change driver manager').take.id)
		  		rp.save!
		  		rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'edit companies').take.id)
		  		rp.save!
		  		rp = RolePermission.new(:role_id => role.id, :permission_id => Permission.where(:description => 'archive users').take.id)
		  		rp.save!
	  	end

	end

	class UserPermission < ActiveRecord::Base
		belongs_to :permission
		belongs_to :user

		validates_presence_of :user_id, :permission_id
	end

	class Permission < ActiveRecord::Base
		def self.create_basic_permissions
			p = Permission.new(:description => "create period")
	  		p.save!
	  		p = Permission.new(:description => "close period")
	  		p.save!
			p = Permission.new(:description => "see drivers list")
			p.save!
			p = Permission.new(:description => "see driver details")
			p.save!
			p = Permission.new(:description => "see driver trips list")
			p.save!
			p = Permission.new(:description => "update driver details")
			p.save!
			p = Permission.new(:description => "change driver password")
			p.save!
			p = Permission.new(:description => "change driver password without current")
			p.save!
			p = Permission.new(:description => "see company trips list")
			p.save!
			p = Permission.new(:description => "see trips details")
			p.save!
			p = Permission.new(:description => "see points list")
			p.save!
			p = Permission.new(:description => "update trips details")
			p.save!
			p = Permission.new(:description => "see reports")
			p.save!
			p = Permission.new(:description => "see settings")
			p.save!
			p = Permission.new(:description => "reopen period")
			p.save!
			p = Permission.new(:description => "move trip")
			p.save!
			p = Permission.new(:description => "refresh mileage")
			p.save!
			p = Permission.new(:description => "see companies list")
			p.save!
			p = Permission.new(:description => "create company")
			p.save!
			p = Permission.new(:description => "create vehicles")
			p.save!
			p = Permission.new(:description => "update vehicles")
			p.save!
			p = Permission.new(:description => "see vehicles list")
			p.save!
			p = Permission.new(:description => "see vehicle details")
			p.save!
			p = Permission.new(:description => "see company index")
			p.save!
			p = Permission.new(:description => "see other users")
			p.save!
			p = Permission.new(:description => "grant permissions")
			p.save!
			p = Permission.new(:description => "create users")
			p.save!
			p = Permission.new(:description => "create trips")
			p.save!
			p = Permission.new(:description => "create drivers")
			p.save!
			p = Permission.new(:description => "manage roles")
			p.save!
			p = Permission.new(:description => "see autoview")
			p.save!
			p = Permission.new(:description => "synchronize logs")
			p.save!
			p = Permission.new(:description => "change period start mileage")
			p.save!	
			p = Permission.new(:description => "see appointments list")
			p.save!
			p = Permission.new(:description => "create appointments")
			p.save!
			p = Permission.new(:description => "edit appointments")
			p.save!
			p = Permission.new(:description => "manage scheduler")
			p.save!
			p = Permission.new(:description => "see scheduler")
			p.save!
			p = Permission.new(:description => "see inspections")
			p.save!
			p = Permission.new(:description => "change driver manager")
			p.save!
			p = Permission.new(:description => "edit companies")
			p.save!
			p = Permission.new(:description => "archive users")
			p.save!
		end
	end

	class RolePermission < ActiveRecord::Base
		belongs_to :role
		belongs_to :permission

		validates_presence_of :role_id, :permission_id
		
	end




  def change
  	ActiveRecord::Base.transaction do
	  	Permission.create_basic_permissions
	  	Role.create_basic_roles
	  	Role.assign_permissions_to_roles
	  	User.assign_roles
	  	Company.fill_blank_db
	end

  	#remove_column :users, :user_type
  	#remove_column :users, :is_line_manager
  	#remove_column :users, :manager_type
  end
end

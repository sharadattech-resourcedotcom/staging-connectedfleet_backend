require 'digest/sha2'

class User < ActiveRecord::Base
  has_many :trips
  has_many :points
  has_many :tokens
  has_many :devices
  has_many :periods, :class_name => 'Period', :foreign_key => 'user_id'
  has_many :mobile_logs
  has_many :user_permissions
  has_many :permissions, through: :user_permissions
  has_one :manager, :class_name => "ManagerDriver", :foreign_key => 'driver_id'
  belongs_to :company, :class_name => 'Company', :foreign_key => 'company_id'
  belongs_to :role, :class_name => 'Role', :foreign_key => 'role_id'
  belongs_to :driver_type, :class_name => 'DriverType', :foreign_key => 'driver_type_id'
  belongs_to :branch, :class_name => 'Branch', :foreign_key => 'branch_id'
  has_many :user_permissions
  has_many :user_vehicles

  validates_presence_of :first_name, :last_name, :password, :email, :salt, :role_id, :company_id
  validates_uniqueness_of :email
  
  EMAIL_REGEX = /\A[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\z/i

  def change_password(newpassword, oldpassword, session_user)
    if session_user.can("change driver password without current")
      self.salt = BCrypt::Engine.generate_salt
      self.password = self.encrypt_password(newpassword, self.salt)
      self.save!
    else
      if self.match_password(oldpassword)
        if  session_user.id == self.id
          self.salt = BCrypt::Engine.generate_salt
          self.password = self.encrypt_password(newpassword, self.salt)
          self.save
        else
          return {:status => false, :errors => ['You have no permission to change this password'], :data => {}}
        end
      else
        return {:status => false, :errors => ['Current password do not match'], :data => {}}
      end
    end

    return {:status => true, :errors => [], :data => {}}
  end
  
  # authenticate user by email and password
  # return false|User
  def self.authenticate(em="", password="")
    if EMAIL_REGEX.match(em)
      user =  User.where('lower(email) = ?', em.downcase).take
    else
      return false
    end

    if user && user.match_password(password)
      return user
    else
      return false
    end
  end
  
  def self.company_drivers(company_id)
    return User.all_with_permissions(company_id, ['work as driver'])
  end

  def self.company_managers(company_id)
    return User.all_with_permissions(company_id, ['be the manager'])
  end

  def match_password(login_password="")
    return (self.password.downcase.to_s == Digest::SHA512.hexdigest(login_password + ' ' + salt).downcase.to_s)
  end  

  def self.company_users_ids(company_id)
    users_ids = []
    User.where(:company_id => company_id).each do |u|
      if u.active
        users_ids.push(u.id)
      end
    end
    return users_ids
  end
  
  def encrypt_password(pass, salt)
    return Digest::SHA512.hexdigest(pass + ' ' + salt)
  end
  #V***************NEW****************V
  
  def is_user_manager(user_id)
    if ManagerDriver.where(:driver_id => user_id).take.manager_id == self.id
      return true
    else
      return false
    end
  end

  def manager_id
    md = ManagerDriver.where(:driver_id => self.id).take
    return md.manager_id if !md.nil?
    return nil 
  end

  def is_manager
    if !self.role_id.nil? && self.role.description == 'Company Head'
      return true
    else
      return false
    end
  end

  def is_line_manager
    if !self.role_id.nil? && self.role.description == 'Line Manager'
      return true
    else
      return false
    end
  end

  def is_admin
    if !self.role_id.nil? && self.role.description == 'Admin'
      return true
    else
      return false
    end
  end

  def full_name
    return self.first_name + ' ' + self.last_name
  end

  def daily_security_code
    return  Digest::SHA512.hexdigest(Date.yesterday.to_s + self.id.to_s).gsub(/[a-zA-Z ]/,'').first(4)
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

    if u.valid?
        u.save
        User.assign_role_permissions(u)
        if u.can('work as driver')
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

  def can(permission)
    # self.permissions.each do |p|
      if self.permissions.map(&:description).include?(permission)
        return true
      end
    return false;
  end

  # def permissions
  #   permissions = []
  #   user_permissions = self.user_permissions.all.eager_load(:permission)
  #   user_permissions.each do |p|
  #     permissions.push(p.permission)
  #   end

  #   return permissions
  # end

  def vehicles
    vehicles = []
    user_vehicles = self.user_vehicles.all.eager_load(:vehicle)
    user_vehicles.each do |uv|
      vehicles.push(uv.vehicle)
    end

    return vehicles
  end

    def self.assign_role_permissions(user)
        role_permissions = RolePermission.where(:role_id => user.role_id)

        role_permissions.each do |rp|
            up = UserPermission.new
            up.user_id = user.id
            up.permission_id = rp.permission_id
            up.save
        end
    end

  def full_name
    full_name = self.first_name+" "+self.last_name
    return full_name
  end

  def role_description
    role = self.role.description if !self.role.nil?
    return role
  end

    def vehicles_ids
        vehicles = self.vehicles
        ids = []
          vehicles.each do |v|
            ids.push(v.id)
          end

        return ids
    end

  def self.all_with_role(role)
        return User.where(:role_id => Role.where(:description => role).take.id).where(:active => true)
  end

  def self.all_with_permissions(company_id, permissions)
        return User.joins(:permissions).where("company_id = ? AND active = TRUE AND permissions.description IN (?)", company_id, permissions )
  end

  def self.assignRoles 
    User.eager_load(:role).all.each do |u|
      if u.user_type == 1
        u.role = Role.where("description = 'Driver'").take
        u.save!
      elsif u.user_type == 4 && u.manager_type == "ADMIN" 
        u.role = Role.where("description = 'Admin'").take
        u.save!
      end
    end
  end

  def company_info
    return self.company
  end

  def dict(fields)
    user = {}
    if !fields.nil?
       user['id'] = self.id if fields.include?('id')
       user['api_version'] = self.api_version if fields.include?('api_version')
       user['app_version'] = self.app_version if fields.include?('app_version')
       user['company_id'] = self.company_id if fields.include?('company_id')
       user['email'] = self.email if fields.include?('email')
       user['first_name'] = self.first_name if fields.include?('first_name')
       user['last_name'] = self.last_name if fields.include?('last_name')
       user['last_login'] = self.last_login if fields.include?('last_login')
       user['last_sync'] = self.last_sync if fields.include?('last_sync')
       user['role_id'] = self.role_id if fields.include?('role_id')
       user['phone'] = self.phone if fields.include?('phone')
       user['payroll_number'] = self.payroll_number if fields.include?('payroll_number')
       user['status'] = self.status if fields.include?('status')
       #methods
       user['permissions'] = self.permissions if fields.include?('permissions')
       user['full_name'] = self.full_name if fields.include?('full_name')
       user['role_description'] = self.role_description if fields.include?('role_description')
       user['company_info'] = self.company_info if fields.include?('company_info')
       user['manager_id'] = self.manager_id if fields.include?('manager_id')
       user['driver_type_id'] = self.driver_type_id if fields.include?('driver_type_id')
       user['branch_id'] = self.branch_id if fields.include?('branch_id')
    else
       user['id'] = self.id 
       user['company_id'] = self.company_id
       user['email'] = self.email
       user['first_name'] = self.first_name
       user['last_name'] = self.last_name
       user['role_id'] = self.role_id
       user['phone'] = self.phone
       user['payroll_number'] = self.payroll_number
       user['status'] = self.status
       user['company_info'] = self.company_info
       user['driver_type_id'] = self.driver_type_id
       user['branch_id'] = self.branch_id
       #methods
       user['permissions'] = self.permissions
       user['full_name'] = self.full_name
       user['role_description'] = self.role_description
    end


       return user
  end

  def additional_dict(fields)
    user = {}
    user['security_code'] = self.daily_security_code if fields.include?('security_code')
    return user
  end

  def as_json(options={})
    json = super(:only => options)
    json = dict(options[:fields])
    if !options[:additional].nil?
      json = json.merge(additional_dict(options[:additional]))
    end
    return json
  end 

  def authorize(request_params) 
    requestPermission = Ability.permission(request_params[:controller], request_params[:action])
    return self.can(requestPermission)
  end

end

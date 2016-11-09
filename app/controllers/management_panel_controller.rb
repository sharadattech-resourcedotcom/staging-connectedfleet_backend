class ManagementPanelController < ApplicationController
	MANAGERS_IDS = [nil, 35, 25, 79, 49, 43, 33, 15]

	def fetch_permissions_data
		roles = available_roles
		permissions = Permission.all
		users = @session_user.company.users.all.eager_load(:user_permissions)
		users = users.sort_by { |driver| [driver.last_name, driver.first_name] }
		return render :json => {:status => true, :errors => {}, :data => {:roles =>roles, :permissions => permissions, :users => users}}
	end

	def fetch_roles_data
		roles = available_roles
		permissions = Permission.all
		return render :json => {:status => true, :errors => {}, :data => {:roles =>roles, :permissions => permissions}}
	end

	def available_roles
		if @session_user.role.description == 'Admin'
			roles = Role.all.eager_load(:role_permissions);
		else
			roles = Role.where("access_level <= ?", @session_user.role.access_level)
		end
		return roles
	end

	def fetch_managers_and_drivers
		managers = User.company_managers(@session_user.company_id)
		drivers = User.company_drivers(@session_user.company_id)
		managers = managers.sort_by { |driver| [driver.last_name, driver.first_name] }
		drivers = drivers.sort_by { |driver| [driver.last_name, driver.first_name] }

		return render :json => {:status => true, :errors => {}, :data => {:managers => managers.as_json(:fields => ['id', 'full_name']),
																		 :drivers => drivers.as_json(:fields => ['id', 'full_name', 'manager_id'])}}
	end

	def assign_manager_to_driver
		if !ManagerDriver.ids_in_hierarchy(User.find(params[:driver_id])).include?(params[:manager_id].to_i)
			manager_driver = ManagerDriver.where("driver_id = ?", params[:driver_id]).take
			if manager_driver.nil?
				manager_driver = ManagerDriver.new
				manager_driver.driver_id = params[:driver_id]
				manager_driver.manager_id = params[:manager_id]
				manager_driver.save!
			else
				manager_driver.update_attributes(manager_id: params[:manager_id])
			end
			driver = User.find(params[:driver_id].to_i)
			if MANAGERS_IDS.include?(params[:manager_id].to_i)
				driver.update_attribute(:marker_type, MANAGERS_IDS.index(params[:manager_id]))
			else
				driver.update_attribute(:marker_type, 0)
			end
			return render :json => {:status => true, :errors => [], :data => {}}
		else
			return render :json => {:status => false, :errors => ["This manager can't oversee this driver because he is lower in the hierarchy."], :data => {}}
		end
	end

	def fetch_settings_data
		set = Settings.find_by_company_id(@session_user.company_id)
		if set.nil?
			set = Settings.create(:company_id => @session_user.company_id)
		end

		branches = Branch.where(:company_id => @session_user.company_id)
		products = Product.where(:company_id => @session_user.company_id)
		insurance_companies = InsuranceCompany.where(:company_id => @session_user.company_id)
		email_templates = CompanyEmail.where(:company_id => @session_user.company_id)
		email_variables = CompanyEmail.variables
		email_types = CompanyEmail.types
		return render :json => {:status => true, :errors => {}, :data => {:lines_values => set, :branches => branches, :products => products,
																		 :insurance_companies => insurance_companies, :email_templates => email_templates,
																		 :email_types => email_types, :email_variables => email_variables}}	
	end

	def remove_settings_value
		case params[:table_name]
			when 'branches'
				branch = Branch.find(params[:element_id])
				if !branch.destroy
					return render :json => {:status => false, :errors => branch.errors.full_messages, :data => {}}
				end

			when 'products'
				product = Product.find(params[:element_id])
				if !product.destroy
					return render :json => {:status => false, :errors => product.errors.full_messages, :data => {}}
				end

			when 'insurance_companies'
				insurance_company = InsuranceCompany.find(params[:element_id])
				if !insurance_company.destroy
					return render :json => {:status => false, :errors => insurance_company.errors.full_messages, :data => {}}
				end
		end
		return render :json => {:status => true, :errors => [], :data => {}}
	end

	def update_settings_data
		unless params[:lines_values].nil?
			set = Settings.find_by_company_id(@session_user.company_id).first
			set[:red_line_value] = params[:lines_values][:redValue].to_i
			set[:orange_line_value] = params[:lines_values][:orangeValue].to_i
			set[:rpm_limit] = params[:lines_values][:rpm_limit].to_f
			set[:fuel_limit] = params[:lines_values][:fuel_limit].to_f
			set[:rpm_points] = params[:lines_values][:rpm_points].to_f
			set[:fuel_points] = params[:lines_values][:fuel_points].to_f
			set.save!
		end

		unless params[:branch].nil?
			# Branch.all.each do |b|
			# 	if b.description == params[:branch]
			# 		return render :json => {:status => false, :errors => ['Branch with such description already exist in database.'], :data => {}}
			# 	end
			# end
			branch = Branch.new
			branch.company_id = @session_user.company_id
			branch.description = params[:branch]
			branch.save!
		end

		unless params[:product].nil?
			# Product.all.each do |p|
			# 	if p.description == params[:product]
			# 		return render :json => {:status => false, :errors => ['Product with such description already exist in database.'], :data => {}}
			# 	end
			# end
			product = Product.new
			product.company_id = @session_user.company_id
			product.description = params[:product]
			product.save!
		end

		unless params[:insurance_company].nil?
			# InsuranceCompany.all.each do |ic|
			# 	if ic.name == params[:insurance_company]
			# 		return render :json => {:status => false, :errors => ['Insurance company with the same name already exist in database.'], :data => {}}
			# 	end
			# end
			insurance_company = InsuranceCompany.new
			insurance_company.company_id = @session_user.company_id
			insurance_company.name = params[:insurance_company]
			insurance_company.save!
		end

		unless params[:email].nil?
			email = CompanyEmail.where("company_id = ? AND email_type = ?", @session_user.company_id, params[:email][:email_type]).take
			params[:email][:company_id] = @session_user.company_id
			puts params
			if email.nil?
				email = CompanyEmail.new(email_params)
				if email.valid?
					email.save!
					return render :json => {:status => true}
				else
					return render :json => {:status => false, :errors => email.errors.full_messages}
				end
			else
				if email.update_attributes(email_params)
					return render :json => {:status => true}
				else
					return render :json => {:status => false, :errors => email.errors.full_messages}
				end
			end
		end

		return render :json => {:status => true, :errors => {}, :data => {}}
	end

	def fetch_create_user_data
		return render :json => {:status => true, :errors => {}, :data => {
			:roles => available_roles,
			:branches => @session_user.company.branches
		}}
	end

	def vehicles_access_users
		users = User.all_with_permissions(@session_user.company_id, ['see inspections', 'see scheduler', 'see appointments list'])
		vehicles = Vehicle.where(:company_id => @session_user.company_id)
		users = users.sort_by { |driver| [driver.last_name, driver.first_name] }
		
		return render :json => {:status => true, :errors => {}, :data => {:users => users, :vehicles => vehicles}}
	end

	def user_vehicles
		vehicles = User.where(:id => params[:user_id]).take.vehicles
		return render :json => {:status => true, :errors => {}, :data => {:vehicles => vehicles}}
	end

	def save_user_vehicles
		ActiveRecord::Base.transaction do
			user = User.where(:id => params[:user_id]).take
			user.user_vehicles.destroy_all
			
			if !params[:vehicles].empty?
				params[:vehicles].each do |v|
					vehicle = user.user_vehicles.new
					vehicle.assign_attributes(:vehicle_id => v[:id])
					vehicle.save!
				end
			end
			return render :json => {:status => true, :errors => {}, :data => {}}
		end
		return render :json => {:status => false, :errors => user.errors.full_messages, :data => {}}
	end

	def fetch_logs
		if !params[:searchForm].nil?
			searchForm = params[:searchForm]

			logs = ApiLogger.all.where(:web_checked => false).eager_load(:user)
			logs = logs.where("created_at >= ?", searchForm[:date_from]).order(:created_at) if !searchForm[:date_from].nil? && searchForm[:date_from] != ''
			logs = logs.where("created_at <= ?", searchForm[:date_to]).order(:created_at) if !searchForm[:date_to].nil? && searchForm[:date_to] != ''
			logs = logs.where("CONCAT(users.first_name, ' ', users.last_name) ilike '%"+searchForm[:driver]+"%'").order(:created_at) if !searchForm[:driver].nil? && searchForm[:driver] != ''
			if !searchForm[:succeeded] || !searchForm[:not_succeeded]
				logs = logs.where("succeeded = ?", (searchForm[:succeeded] == true ? 1 : 0)).order(:created_at) if !searchForm[:succeeded].nil? 
			end  
			
			if !searchForm[:date_to] != '' && !searchForm[:date_to].nil? && searchForm[:date_from] != '' && !searchForm[:date_from].nil? 
			else
				logs = logs.first(30)
			end
		else
			logs = ApiLogger.last(30)
		end
		if logs.size > 1000
			logs= logs.first(1000)
		end
		#logs = logs.reverse!
		return render :json => {:status => true, :data => {:logs => logs}}
	end

	def synchronize_log
		require 'net/http'
    	require 'uri'

	    #uri = URI 'http://127.0.0.1:8001/driver/synchronize'
	    uri = URI 'http://46.17.215.204:42365/driver/synchronize'
	    headers = {"Content-Type" => "application/json",           
                         'Accept-Encoding'=> "gzip,deflate",
                         'Accept' => "application/json",
                     	 'App-Version' => '2.0'}

	    http = Net::HTTP.new(uri.host,uri.port)
	    response = http.post(uri.path,params[:data] , headers)
	    if response.body.exclude? '"status": false'
	    	log = ApiLogger.where(:id => params[:log_id]).take
	    	ApiLogger.checked(log.input_val)
	    	return render :json => {:status => true, :errors => [], :data => {:response => response.body}}
	    else
	    	response_body = response.body.to_json.gsub! '\\', ''
	    	response_body = response_body.gsub! '"{', '{'
	    	response_body = response_body.gsub! '}"', '}'
	    	return render :json => {:status => false, :errors => ['Synchronization failed.', response_body], :data => {:response => response.body}}
	    end
	end

	def save_roles
		ActiveRecord::Base.transaction do
			roles = params[:roles]
			roles.each do |r|
				role = Role.find(r[:id])
				role.update_attributes(:access_level => r[:access_level])
				role.change_role_permissions(r[:permissions])
			end
			return render :json => {:status => true, :errors => {}, :data => {}}
		end
		return render :json => {:status => false, :errors => {}, :data => {}}
	end

	def new_role
		ActiveRecord::Base.transaction do
			role = Role.new
			role.description = params[:role][:description]
			role.access_level = params[:role][:access_level]
			if role.valid?
				role.save!
				
				params[:role][:permissions].each do |p|
					permission = role.role_permissions.new
					permission.assign_attributes(:permission_id => p[:id])
					permission.save!
				end
				return render :json => {:status => true, :errors => {}, :data => {}}
			else
				return render :json => {:status => true, :errors => role.errors.full_messages, :data => {}}
			end
		end

		return render :json => {:status => false, :errors => {}, :data => {}}
	end

	def save_user_permissions
		ActiveRecord::Base.transaction do
			param_user = params[:user]
			user = User.where(:id => param_user[:id]).take
			if(param_user[:role_id] != param_user[:selected_role][:id])
				user = User.where(:id => param_user[:id]).take
				user.update_attributes(:role_id => param_user[:selected_role][:id])
			end
			user.user_permissions.each{|x| x.delete}
			
			if !param_user[:permissions].nil?
				param_user[:permissions].each do |p|
					permission = user.user_permissions.new
					permission.assign_attributes(:permission_id => p[:id])
					permission.save!
					if Permission.find(p[:id]).description == 'work as driver'
						if Period.where("user_id = ? AND status = 'opened'", user.id).empty?
				            period = Period.new
				            period.user_id = user.id
				            period.start_date = Date.today
				            period.start_mileage = 0
				            period.status = 'opened'
				            period.save!
						end
					end
				end
			end
			return render :json => {:status => true, :errors => {}, :data => {}}
		end
		return render :json => {:status => false, :errors => {}, :data => {}}
	end

	def create_user
		ActiveRecord::Base.transaction do
			user = User.create(params[:user], @session_user.company_id)
			# if user.valid?
			# 	if !params[:user][:permissions].nil?
			# 		params[:user][:permissions].each do |p|
			# 			permission = user.user_permissions.new
			# 			permission.assign_attributes(:permission_id => p[:id])
			# 			permission.save!
			# 		end
			# 	end
			# else
			# 	return render :json => {:status => false, :errors => user.errors.full_messages, :data => {}}
			# end
			if user.valid?
				return render :json => {:status => true, :errors => [], :data => {}}
			else
				return render :json => {:status => false, :errors => user.errors.full_messages, :data => {}}
			end
		end
		return render :json => {:status => false, :errors => @error, :data => {}}
	end

	def fetch_sales_staff
		users = User.where(:company_id => @session_user.company_id).sort_by { |user| [user.last_name, user.first_name] }
		staff_users = []
		staff = SalesStaff.joins(:user).where(:company_id => @session_user.company_id)
		ids = []
	      staff.each do |s|
	          ids.push(s.user_id)
	      end
	    staff_users = User.where("id IN (" + ids.join(',') + ")").sort_by { |user| [user.last_name, user.first_name] } if !ids.empty?
	    users = users - staff_users
	    email = CompanyEmail.where("company_id = ? AND email_type = 'Sales Staff'", @session_user.company_id).take
		return render :json => {:status => true, :errors => [], :data => {:available_users => users.as_json(:fields => ['id', 'full_name']), :staff_users => staff_users.as_json(:fields => ['id', 'full_name']), :email => email}}
	end

	def save_sales_staff
		ActiveRecord::Base.transaction do
			puts params
			SalesStaff.where(:company_id => @session_user.company_id).destroy_all
			if !params[:staff_users].empty?
				params[:staff_users].each do |u|
					staff = SalesStaff.new
					staff.user_id = u[:id]
					staff.company_id = @session_user.company_id if User.find(u[:id]).company_id == @session_user.company_id
					staff.save! if staff.valid?
					puts staff.errors.full_messages
				end
			end
			return render :json => {:status => true, :errors => {}, :data => {}}
		end
		return render :json => {:status => false, :errors => staff.errors.full_messages, :data => {}}
	end

	def upload_apk
		# if params[:file].content_type == "application/vnd.android.package-archive"
		begin 
			front_name = params[:file].original_filename.split("_")[0].downcase + ".apk"
			front_dir = Rails.root.join('..', 'connectedfleet_frontend')
			name = Time.now.utc.to_i.to_s + "_" + params[:company_id].to_s + "_" + params[:version_name].to_s + "_" + params[:version_code] + ".apk" 
			directory = "#{Rails.root}/public/apps/"
			path = File.join(directory, name)
			File.open(path, "wb") { |f| f.write(params[:file].read) }
			v = AppVersion.create(params, name)
			if v.valid?
				path = File.join(front_dir, front_name)
				File.open(path, "wb") { |f| f.write(params[:file].read) }
				return render :json => {:status => true, :errors => [], :data => {}}
			else
				return render :json => {:status => false, :errors => v.errors.full_messages, :data => {}}
		 	end
		rescue => ex
            return render :json => {:status => false, :errors => [ex.to_s], :data => {}}
        end
		# else
		# 	return render :json => {:status => false, :errors => ["Wrong file type."], :data => {}}
		# end
	end

	def jenkins_upload_apk
		# if params[:file].content_type == "application/vnd.android.package-archive"
		begin 
			front_name = params[:file].original_filename.split("_")[0].downcase + ".apk"
			front_dir = Rails.root.join('..', 'connectedfleet_frontend')
			name = Time.now.utc.to_i.to_s + "_" + params[:company_id].to_s + "_" + params[:version_name].to_s + "_" + params[:version_code] + ".apk" 
			directory = "#{Rails.root}/public/apps/"
			path = File.join(directory, name)
			File.open(path, "wb") { |f| f.write(params[:file].read) }
			v = AppVersion.create(params, name)
			if v.valid?
				path = File.join(front_dir, front_name)
				File.open(path, "wb") { |f| f.write(params[:file].read) }
				return render :json => {:status => true, :errors => [], :data => {}}
			else
				return render :json => {:status => false, :errors => v.errors.full_messages, :data => {}}
		 	end
		rescue => ex
            return render :json => {:status => false, :errors => [ex.to_s], :data => {}}
        end
		# else
		# 	return render :json => {:status => false, :errors => ["Wrong file type."], :data => {}}
		# end
	end

	private
		def user_params
				params.require(:user).permit(:first_name, :last_name, :password, :phone, :role_id, :email)
		end

		def email_params
				params.require(:email).permit(:company_id, :email_type, :subject, :recipients, :content)
		end

end
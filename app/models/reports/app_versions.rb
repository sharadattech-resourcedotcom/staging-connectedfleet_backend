class Reports::AppVersions
	def self.info
		return {:name => 'App Versions', :key => 'appVersions'} 
	end

	def self.generate(user, date_from, date_to, params)
		columns = ['First Name', 'Last Name', 'Email', 'App Version', 'Version Code', 'Device Model', 'Last sync date']
		values = []
		users = User.where('id IN (' + ManagerDriver.manager_drivers_ids(user.company, user).join(',') + ')')
		users = users.sort_by { |user| [user.last_name, user.first_name] }
		users.each do |u|
			last_sync = u.last_sync
			last_sync = last_sync.strftime("%d/%m/%Y %H:%M") if !last_sync.nil?
			values.push([ u.first_name, u.last_name, u.email, u.app_version, u.app_version_code, u.last_device, last_sync])
		end

		return [columns, values]
	end
end

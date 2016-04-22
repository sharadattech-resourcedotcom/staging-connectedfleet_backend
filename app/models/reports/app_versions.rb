class Reports::AppVersions
	def self.info
		return {:name => 'App Versions', :key => 'appVersions'} 
	end

	def self.generate(user, date_from, date_to, params)
		columns = ['First Name', 'Last Name', 'Email', 'App Version', 'Version Code', 'Last sync date']
		values = []
		users = User.where('id IN (' + ManagerDriver.manager_drivers_ids(user.company, user).join(',') + ')')
		users = users.sort_by { |user| [user.last_name, user.first_name] }
		users.each do |u|
			last_sync = u.last_sync
			last_sync = last_sync.strftime("%d/%m/%Y %H:%M") if !last_sync.nil?
			version_code = ApiLogger.where("user_id = ?", u.id).last
			version_code = version_code.app_version_code if !version_code.nil?
			values.push([ u.first_name, u.last_name, u.email, u.app_version, version_code, last_sync])
		end

		return [columns, values]
	end
end

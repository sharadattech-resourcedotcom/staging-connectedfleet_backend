class Reports::ManagersOfDrivers
	def self.info
		return {:name => 'Managers of drivers', :key => 'managersOfDrivers'} 
	end

	def self.generate(user, date_from, date_to, params)
		columns = ['Driver', 'Driver email', 'Manager', 'Manager email']
		values = []
		drivers = User.company_drivers(user.company_id)
		drivers = drivers.where("tester = FALSE").sort_by { |driver| [driver.last_name, driver.first_name] }
		drivers.each do |d|
			manager_driver = ManagerDriver.where(:driver_id => d.id).take
			if manager_driver.nil?
				values.push([ d.full_name, d.email, "Unknown","Unknown"])
			else
				manager = manager_driver.manager
				values.push([ d.full_name, d.email, manager.full_name,manager.email])
			end
			
			
		end

		return [columns, values]
	end
end

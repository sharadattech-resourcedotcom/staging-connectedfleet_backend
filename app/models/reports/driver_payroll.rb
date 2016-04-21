class Reports::DriverPayroll
	def self.info
		return {:name => 'Driver Payroll', :key => 'driver_payroll'} 
	end


	def self.generate(user, date_from, date_to, params)
		columns = ['First Name', 'Last Name', 'Trips No.', 'Hours', 'Miles']
		values = []

		users = ManagerDriver.manager_drivers(user.company, user)
		users = users.where("tester = FALSE")
		return [columns, values] if users.length == 0

		users.each do |u|
			trips = u.trips.where("status = 'finished' AND start_date >= DATE(?) AND start_date <= DATE(?)", date_from, date_to)
			hours = 0
			miles = 0
			
			trips.each do |t|
				hours = hours + t.duration
				miles = miles + t.mileage
			end

			values.push([
				u.first_name,
				u.last_name,
				trips.length,
				sprintf("%.2f", hours),
				miles
			])
		end

		return [columns, values]
	end
end
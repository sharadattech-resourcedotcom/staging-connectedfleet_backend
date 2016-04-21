class Reports::DriverPayrollDetailed
	def self.info
		return {:name => 'Driver Payroll (Detailed)', :key => 'driver_payroll_detailed'} 
	end


	def self.generate(user, date_from, date_to, params)
		columns = ['First Name', 'Last Name', 'Date', 'Trips No.', 'Hours', 'Miles']
		values = []

		users = ManagerDriver.manager_drivers(user.company, user)
		users = users.where("tester = FALSE")
		return [columns, values] if users.length == 0

		users.each do |u|
			trips = u.trips.where("status = 'finished'")
			
			(Date.parse(date_from)..Date.parse(date_to)).each do |da|
				hours = 0
				miles = 0

				day_trips = trips.select{|x| x.start_date.to_date == da}
				day_trips.each do |t|
					hours = hours + t.duration
					miles = miles + t.mileage
				end

				values.push([
					u.first_name,
					u.last_name,
					da.strftime("%d/%m/%Y"),
					day_trips.length,
					sprintf("%.2f", hours),
					miles
				])
			end
		end

		return [columns, values]
	end
end
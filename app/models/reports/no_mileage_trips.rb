class Reports::NoMileageTrips
	def self.info
		return {:name => 'Trips Duration', :key => 'trips_duration', :dates => 'range'} 
	end

	def self.generate(user, date_from, date_to, params)
		columns = ["Pay. Number", "First Name", 'Last Name', 'Email','Start date', 'End Date', 'Duration',
					'Status', 'Trip vehicle']
		values = []

		trips = Trip.where('DATE(trips.start_date) >= ? AND DATE(trips.start_date) <= ? AND users.company_id = ?  AND users.tester = FALSE', Date.parse(date_from), Date.parse(date_to), user.company_id)
		trips = trips.where('users.id IN (' + ManagerDriver.manager_drivers_ids(user.company, user).join(',') + ')')
		trips = trips.order('trips.id DESC')
		trips = trips.eager_load([:user])
		trips = trips.sort_by { |trip| [trip.user.last_name, trip.user.first_name, trip.start_date] }


		trips.each do |t|			
			duration = "At the time"
			duration = ((t.end_date - t.start_date) / 1.hours).round(2).to_s + " h" if !t.end_date.nil?
			end_date = t.end_date.in_time_zone('London')
			end_date = end_date.in_time_zone('London').strftime("%d/%m/%Y %H:%M") if !end_date.nil?
			values.push([
				t.user.payroll_number, t.user.first_name, t.user.last_name, t.user.email, t.start_date.strftime("%d/%m/%Y %H:%M"), end_date,
		 		duration, t.status, t.vehicle_reg_number])
		end

		return [columns, values]
	end
end

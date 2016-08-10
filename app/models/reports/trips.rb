class Reports::Trips
	def self.info
		return {:name => 'Trips', :key => 'trips', :dates => 'range'} 
	end

	def self.generate(user, date_from, date_to, params)
		columns = ["Pay. Number", "First Name", 'Last Name', 'Email','Start date', 'End Date',
					'Start mileage', 'End mileage','Status', 'Trip vehicle', 'Agent email', 'Business mileage', 'Private mileage', 'Opening mileage', 'Closing mileage']
		values = []

		trips = Trip.where('DATE(trips.start_date) >= ? AND DATE(trips.start_date) <= ? AND users.company_id = ?  AND users.tester = FALSE', Date.parse(date_from), Date.parse(date_to), user.company_id)
		trips = trips.where('users.id IN (' + ManagerDriver.manager_drivers_ids(user.company, user).join(',') + ')')
		trips = trips.order('trips.id DESC')
		trips = trips.eager_load([:user, :period])
		trips = trips.sort_by { |trip| [trip.user.last_name, trip.user.first_name, trip.start_date] }


		trips.each do |t|			
			end_date = t.end_date
			end_date = end_date.in_time_zone('London').strftime("%d/%m/%Y %H:%M") if !end_date.nil?
			if t.period.nil?
				values.push([
					t.user.payroll_number, t.user.first_name, t.user.last_name, t.user.email, t.start_date.in_time_zone('London').strftime("%d/%m/%Y %H:%M"), end_date,
			 		t.start_mileage, t.end_mileage, t.status, t.vehicle_reg_number, nil, t.mileage, t.private_mileage, nil, nil ])
			else
				values.push([
					t.user.payroll_number, t.user.first_name, t.user.last_name, t.user.email, t.start_date.in_time_zone('London').strftime("%d/%m/%Y %H:%M"), end_date,
			 		t.start_mileage, t.end_mileage, t.status, t.vehicle_reg_number, t.period.agent_email, t.mileage, t.private_mileage, t.period.start_mileage, t.period.end_mileage ])
			end
		end

		return [columns, values]
	end
end

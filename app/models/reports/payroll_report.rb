class Reports::PayrollReport
	def self.info
		return {:name => 'Payroll', :key => 'payrollReport'} 
	end

	def self.generate(user, period_date, nil_param, params)
		columns = ["Employee Number", " Employee Name", "Reg No.", "Opening Odometer", "Closing Odometer", 
				 "Total mileage", "Total Business mileage", "Total Private mileage", "Agent email"]
		values = []
		start_date = Date.parse(period_date).change(:day => 1)
		end_date = start_date.end_of_month

		trips = Trip.eager_load(:period, :user, :vehicle).where("users.company_id = ? AND users.tester = FALSE AND periods.start_date > ? AND periods.end_date < ? AND trips.end_date IS NOT NULL", user.company_id, start_date - 1.week, end_date + 1.week).order("users.last_name ASC, users.first_name ASC")
		periods_ids = trips.pluck(:period_id).uniq
		periods_ids.each do |period_id|
			period_trips = trips.select{|t| t.period_id == period_id}.sort_by{|t| t.end_date}
			period = period_trips.first.period
			vehicles_ids = period_trips.map(&:vehicle_id).uniq
			vehicles_ids = vehicles_ids - [nil]
			vehicles_ids.each do |vehicle_id|
				vehicle = period_trips.select{|t| t.vehicle_id == vehicle_id}.first.vehicle
			 	vehicle_last_trip = Period.last_trip_by_vehicle(vehicle, period_trips)
			 	start_mileage = Period.first_trip_by_vehicle(vehicle, period_trips).start_mileage
			 	end_mileage = vehicle_last_trip.end_mileage
			 	business_mileage = Period.business_mileage_by_vehicle(vehicle, period_trips)
			 	private_mileage =  Period.privete_mileage_by_vehicle(vehicle, period_trips)
			 	if period_trips.last.id == vehicle_last_trip.id && !period.end_mileage.nil?
			 		end_mileage = period.end_mileage
			 	end
				values.push([
					period_trips.first.user.payroll_number,
					period_trips.first.user.last_name + " " + period_trips.first.user.first_name,
					vehicle.registration,
					start_mileage,
					end_mileage,
					business_mileage + private_mileage,
					business_mileage,
					private_mileage,
					period.agent_email
				])
			end
		end

		return [columns, values]
	end
end
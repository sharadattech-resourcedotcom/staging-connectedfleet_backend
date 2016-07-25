class Reports::SpeedingOverValue
	def self.info
		return {:name => 'Speeding over value', :key => 'speeding_over_value'} 
	end

	def self.generate(user, date_from, date_to, params)
		columns = ["Driver", "Vehicle registration", "Total instances of speeding", "0-10 mph over", "10-20 mph over", "30+ mph over"]
		values = []
		treshold = params[:value]
		start_date = Date.parse(period_date).change(:day => 1)
		end_date = start_date.end_of_month

		points = Point.includes(:trips, :user, :vehicle).where("users.company_id = ? AND users.tester = FALSE AND trips.start_date > ? AND trips.end_date < ? AND trips.end_date IS NOT NULL", user.company_id, Date.parse(date_from), Date.parse(date_to)).order("users.last_name ASC, users.first_name ASC")
		users_ids = points.pluck(:user_id).uniq
		users_ids.each do |user_id|
			user_points = points.select{|p| p.user_id == user_id}
			vehicles = user_points.map(&:vehicle).uniq
			vehicles.each do |vehicle|
				vehicle_points = user_points.select{|p| p.vehicle == vehicle}
				

				values.push([
					period_trips.first.user.payroll_number,
					period_trips.first.user.last_name + " " + period_trips.first.user.first_name,
					vehicle.registration,
					end_mileage - business_mileage - private_mileage,
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
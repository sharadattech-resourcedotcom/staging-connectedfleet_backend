class Reports::TopTenBehaviour
	def self.info
		return {:name => 'Top Ten Behaviour', :key => 'topBehaviourReport'} 
	end

	def self.generate(user, date_from, date_to, params)
		columns = ['First Name', 'Last Name', 'Average MPG', 'Average MPH', 'Maximum MPH', 'Average RPM', 'BP', 'Hours', 'Miles']
		values = []

		users = User.where('id IN (' + ManagerDriver.manager_drivers_ids(user.company, user).join(',') + ') AND tester = FALSE')
		users = users.sort_by { |user| [user.last_name, user.first_name] }

		users.each do |u|
			trips = Trip.where('user_id = ? AND stats_gen = TRUE AND DATE(start_date) >= ? AND DATE(start_date) <= ?', u.id, Date.parse(date_from), Date.parse(date_to))
			
			speeds = []
			speeds_avg = []
			rpm_avg = []
			fuel_avg = []
			beh_points = []
			dongle_points = []
			hours = 0
			miles = 0

			trips.each do |trip|
				fuel_avg.push(trip.trip_stat.fuel_avg_in_mpg) if !trip.trip_stat.fuel_avg_in_mpg.nil? && trip.trip_stat.fuel_avg_in_mpg > 0
				speeds.push(trip.trip_stat.speed_max) if !trip.trip_stat.speed_max.nil? && trip.trip_stat.speed_max > 0
				speeds_avg.push(trip.trip_stat.speed_avg) if !trip.trip_stat.speed_avg.nil? && trip.trip_stat.speed_avg > 0
				rpm_avg.push(trip.trip_stat.rpm_avg) if !trip.trip_stat.rpm_avg.nil? && trip.trip_stat.rpm_avg > 0
				beh_points.push(trip.trip_stat.behaviour_points)
				hours = hours + ((trip.end_date - trip.start_date) / 1.hour).round
				miles = miles + trip.mileage
			end

			if fuel_avg.length == 0 || speeds_avg.length == 0 ||
				rpm_avg.length == 0 || beh_points.length == 0
				then next
			end

			values.push([
				u.first_name, 
				u.last_name, 
				(fuel_avg.length == 0) ? 0 : (fuel_avg.max.round(2)).round(0),
				(speeds_avg.length == 0) ? 0 : (speeds_avg.max/ 1.609).round(0),
				(speeds.length == 0) ? 0 : (speeds.max/ 1.609).round(0),
				(rpm_avg.length == 0) ? 0 : (rpm_avg.max),
				(beh_points.length == 0) ? 0 : (beh_points.reduce(:+) / beh_points.length).round(2),
				hours,
				miles
			])
		end
		case params[:sort]
	        when 'MPG'
	        	values = values.sort_by() { |v| [-v[2]] }
	        when 'MPH'
	        	values = values.sort_by { |v| [-v[3]] }
	        when 'RPM'
	        	values = values.sort_by { |v| [-v[5]] }
	        when 'BP'
	        	values = values.sort_by { |v| [-v[6]] }
	    end

	    if params[:top] == 3
	    	values = values.first(10)
	    elsif params[:top] == 2
	    	values = values.last(10)
	    end

		return [columns, values]
	end
end
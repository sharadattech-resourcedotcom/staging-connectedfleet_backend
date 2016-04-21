class Reports::DriversSpeedRange
	def self.info
		return {:name => 'Drivers Statistics (Date range)', :key => 'driversSpeedRange'} 
	end

	def self.generate(user, date_from, date_to, params)
		columns = ['First Name', 'Last Name', 'Max speed', 'Avg speed', 'Avg. RPM', 
			'Avg. Fuel', 'Dongle Pts Coll.', 'Avg. Beh. Pts', 'Total Beh. Points', 'Line Manager']
		values = []

		users = User.where('id IN (' + ManagerDriver.manager_drivers_ids(user.company, user).join(',') + ') AND users.tester = FALSE')
		users = users.sort_by { |user| [user.last_name, user.first_name] }

		users.each do |u|
			trips = Trip.where('user_id = ? AND stats_gen = TRUE AND DATE(start_date) >= ? AND DATE(start_date) <= ?', u.id, Date.parse(date_from), Date.parse(date_to))
			
			speeds = []
			speeds_avg = []
			rpm_avg = []
			fuel_avg = []
			beh_points = []
			dongle_points = []

			trips.each do |trip|
				speeds.push(trip.trip_stat.speed_max) if !trip.trip_stat.speed_max.nil? && trip.trip_stat.speed_max > 0
				speeds_avg.push(trip.trip_stat.speed_avg) if !trip.trip_stat.speed_avg.nil? && trip.trip_stat.speed_avg > 0
				rpm_avg.push(trip.trip_stat.rpm_avg) if !trip.trip_stat.rpm_avg.nil? && trip.trip_stat.rpm_avg > 0
				fuel_avg.push(trip.trip_stat.fuel_avg_in_mpg) if !trip.trip_stat.fuel_avg_in_mpg.nil? && trip.trip_stat.fuel_avg_in_mpg > 0
				beh_points.push(trip.trip_stat.behaviour_points)
				dongle_points.push(trip.trip_stat.dongle_points)
			end

			values.push([
				u.first_name, 
				u.last_name, 
				(speeds_avg.length == 0) ? 0 : sprintf("%.0f", speeds.max/ 1.609),
				(speeds_avg.length == 0) ? 0 : sprintf("%.0f", (speeds_avg.reduce(:+) / speeds_avg.length/ 1.609)),
				(rpm_avg.length == 0) ? 0 : sprintf("%.0f", (rpm_avg.reduce(:+) / rpm_avg.length)),
				(fuel_avg.length == 0) ? 0 : sprintf("%.2f", (fuel_avg.reduce(:+) / fuel_avg.length)),
				(dongle_points.length == 0) ? 0 : sprintf("%.0f", (dongle_points.reduce(:+))),
				(beh_points.length == 0) ? 0 : sprintf("%.2f", (beh_points.reduce(:+) / beh_points.length)),								
				(beh_points.length == 0) ? 0 : sprintf("%.2f", (beh_points.reduce(:+))),
				(u.manager.nil?)? 'Unknown' : u.manager.manager.last_name + " " + u.manager.manager.first_name
			])
		end

		return [columns, values]
	end
end
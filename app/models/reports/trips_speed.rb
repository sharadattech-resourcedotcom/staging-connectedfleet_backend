class Reports::TripsSpeed
	def self.info
		return {:name => 'Trips Driving Data', :key => 'tripsSpeed'} 
	end


	def self.generate(user, date_from, date_to, params)
		columns = ['First Name', 'Last Name', 'Start date', 'End date', 'Min speed', 
			'Max speed', 'Avg speed', 'Avg. RPM', 'Avg. Fuel', 'Behav. Pts']
		values = []

		trips = Trip.where('DATE(trips.start_date) >= ? AND DATE(trips.start_date) <= ? AND users.company_id = ? AND users.tester = FALSE AND trips.status = ? AND stats_gen = true ', Date.parse(date_from), Date.parse(date_to), user.company_id, "finished")
		trips = trips.where('users.id IN (' + ManagerDriver.manager_drivers_ids(user.company, user).join(',') + ')')
		trips = trips.eager_load([:user, :trip_stat])
		trips = trips.sort_by { |trip| [trip.start_date, trip.user.last_name, trip.user.first_name] }

		trips.each do |t|
			values.push([
				t.user.first_name, 
				t.user.last_name, 
				t.start_date.in_time_zone('London').strftime("%d/%m/%Y %H:%M"), 
				(t.end_date.nil?) ? '' : t.end_date.in_time_zone('London').strftime("%d/%m/%Y %H:%M"),
				(t.trip_stat.speed_min.nil? || t.trip_stat.speed_min < 0) ? '' : sprintf("%.0f", t.trip_stat.speed_min / 1.609), 
				(t.trip_stat.speed_max.nil? || t.trip_stat.speed_max < 0) ? '' : sprintf("%.0f", t.trip_stat.speed_max / 1.609), 
				(t.trip_stat.speed_avg.nil? || t.trip_stat.speed_avg < 0) ? '' : sprintf("%.0f", t.trip_stat.speed_avg / 1.609),
				(t.trip_stat.rpm_avg < 0) ? '' : t.trip_stat.rpm_avg,
				(t.trip_stat.fuel_avg_in_mpg < 0) ? '' : t.trip_stat.fuel_avg_in_mpg,
				t.trip_stat.behaviour_points
			])
		end

		return [columns, values]
	end
end
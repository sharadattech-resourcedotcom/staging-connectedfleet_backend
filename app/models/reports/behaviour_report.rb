class Reports::BehaviourReport
	def self.info
		return {:name => 'Driving Log', :key => 'behaviourReport'} 
	end

	def self.generate(user, date_from, date_to, params)
		columns = ['First Name', 'Last Name', 'Max speed', 'Max RPM', 
			'Avg. Fuel', 'Hours Logged', 'Avg. Beh. Pts','Behaviour Rate']
		values = []

		users = User.where('id IN (' + ManagerDriver.manager_drivers_ids(user.company, user).join(',') + ') AND tester = FALSE')
		users = users.sort_by { |user| [user.last_name, user.first_name] }
		overal_aver_beh = []

		users.each do |u|
			trips = Trip.where('user_id = ? AND stats_gen = TRUE AND DATE(start_date) >= ? AND DATE(start_date) <= ?', u.id, Date.parse(date_from), Date.parse(date_to))
			
			speeds = []
			speeds_avg = []
			rpm_avg = []
			fuel_avg = []
			beh_points = []
			dongle_points = []
			hours = 0

			trips.each do |trip|
				speeds.push(trip.trip_stat.speed_max) if !trip.trip_stat.speed_max.nil? && trip.trip_stat.speed_max > 0
				speeds_avg.push(trip.trip_stat.speed_avg) if !trip.trip_stat.speed_avg.nil? && trip.trip_stat.speed_avg > 0
				rpm_avg.push(trip.trip_stat.rpm_avg) if !trip.trip_stat.rpm_avg.nil? && trip.trip_stat.rpm_avg > 0
				fuel_avg.push(trip.trip_stat.fuel_avg_in_mpg) if !trip.trip_stat.fuel_avg_in_mpg.nil? && trip.trip_stat.fuel_avg_in_mpg > 0
				beh_points.push(trip.trip_stat.behaviour_points)
				dongle_points.push(trip.trip_stat.dongle_points)
				hours = hours + ((trip.end_date - trip.start_date) / 1.hour).round
			end

			values.push([
				u.first_name, 
				u.last_name, 
				(speeds_avg.length == 0) ? 0 : sprintf("%.0f", speeds.max/ 1.609),
				(rpm_avg.length == 0) ? 0 : sprintf("%.0f", (rpm_avg.max)),
				(fuel_avg.length == 0) ? 0 : sprintf("%.2f", (fuel_avg.reduce(:+) / fuel_avg.length)),
				hours.to_i,
				(beh_points.length == 0) ? 0 : sprintf("%.2f", (beh_points.reduce(:+) / beh_points.length))
			])
			
			overal_aver_beh.push (beh_points.reduce(:+) / beh_points.length) if beh_points.length > 0
		end

		overal_av_b = 0
		overal_av_b = (overal_aver_beh.reduce(:+) / overal_aver_beh.length) if overal_aver_beh.length > 0

		values.each do |v|
			if overal_av_b == 0
				v.push ''
			elsif v.last.to_f == 0
				v.push '.'
			elsif v.last.to_f > overal_av_b
				v.push '-'
			else
				v.push '+'
			end
		end

		return [columns, values]
	end
end
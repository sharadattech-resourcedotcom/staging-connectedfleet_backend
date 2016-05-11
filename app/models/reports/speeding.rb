class Reports::Speeding
	def self.info
		return {:name => 'Speeding', :key => 'speeding'} 
	end

	def self.generate(user, date_from, date_to, params)
		columns = ['Trip ID','Driver', 'Date', 'Points over 77 mph', 'Longer than 30 seconds']
		values = []

		users = User.where('id IN (' + ManagerDriver.manager_drivers_ids(user.company, user).join(',') + ') AND users.tester = FALSE')
		users = users.sort_by { |user| [user.last_name, user.first_name] }

		users.each do |u|
			trips = Trip.where('user_id = ? AND stats_gen = TRUE AND DATE(start_date) >= ? AND DATE(start_date) <= ?', u.id, Date.parse(date_from), Date.parse(date_to))

			trips.each do |trip|
				stat = trip.trip_stat
				values.push([
					trip.id, trip.user.full_name, trip.start_date, stat.speeds_over_123, stat.speeds_over_123_long
				]) if stat.speeds_over_123 > 0
			end
		end

		return [columns, values]
	end
end
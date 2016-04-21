class Reports::TripsStat
	def self.info
		return {:name => 'Trips Stat', :key => 'trips_stat', :dates => 'range'} 
	end

	def self.generate(user, date_from, date_to, params)
		columns = ["ID", "Start date", "End date", "First Name", 'Last Name', 'Total points', 'Dongle Points','Dongle ratio' ,'Bluetooth Ratio']
		values = []

		trips = Trip.where('DATE(trips.start_date) >= ? AND DATE(trips.start_date) <= ? AND users.company_id = ?  AND users.tester = FALSE AND trips.status = ? AND stats_gen = true ', Date.parse(date_from), Date.parse(date_to), user.company_id, "finished")
		trips = trips.where('users.id IN (' + ManagerDriver.manager_drivers_ids(user.company, user).join(',') + ')')
		trips = trips.eager_load([:user, :trip_stat])
		trips = trips.sort_by { |trip| [trip.user.last_name, trip.user.first_name, trip.start_date] }

		trips.each do |t|			
			values.push([
				t.id, 
				t.start_date.strftime("%d/%m/%Y %H:%M"), 
				t.safe_end_date,
				t.user.first_name, 
				t.user.last_name, 
				t.trip_stat.points_total, 
				t.trip_stat.dongle_points, 
				(t.trip_stat.ratio.nil?) ? '' : t.trip_stat.ratio.round(2).to_s + "%",
				(t.trip_stat.bt_ratio.nil?) ? '' : t.trip_stat.bt_ratio.round(2).to_s + "%" 
			])
		end

		return [columns, values]
	end
end

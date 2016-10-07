class PhotomeService
	def self.autoclose_current_periods
		drivers = User.where("company_id = 4 and active = TRUE")
		drivers.each do |driver|
			begin
				ActiveRecord::Base.transaction do
					if driver.can('work as driver')
						opened_periods = driver.periods.where("status = 'opened'")
						if opened_periods.length > 1
							period = opened_periods.sort{|a, b| a.start_date <=> b.start_date}.last
							opened_periods = opened_periods - [period]
							opened_periods.each do |p|
								p.trips.each{|t| t.update_attribute(:period_id, period.id)}
								p.delete
							end
						else
							period = opened_periods.take
						end
						next if period.start_date.month == Date.today.month && period.start_date.year == Date.today.year
						end_date = Time.parse(Date.today.change(:day => 1).to_s).change(:hour => 22).utc.change(:hour => 3)
						manager = driver.manager
						next if manager.nil?
						manager = manager.manager
						last_trip = period.trips.where("end_mileage IS NOT NULL").sort{|a, b| a.start_date <=> b.start_date}.last
						period.close(last_trip.nil? ? 0 : last_trip.end_mileage, manager.email, 'autoclose', end_date)
					end
				end
			rescue => ex
				puts ex.message
				puts ex.backtrace.select { |x| x.match(/#{Rails.root.join('app')}/) }
				next
			end
		end
	end
end
class Reports::Periods
	def self.info
		return {:name => 'Periods', :key => 'periods', :dates => 'range'}
	end

	def self.generate(user, date_from, date_to, params)
		columns = ['ID', 'First Name', 'Last Name', 'Email','Start date', 'End date', 'Status', 'Closed by','Approved', 'Agent email', 'Business mileage','Private mileage', 'Start mileage', 'End mileage' ]
		values = []
		users = []

		periods = Period.where('DATE(start_date) >= ? AND DATE(start_date) <= ?', Date.parse(date_from), Date.parse(date_to))

		if params[:approved] == 'false' || params[:approved] == 'true'
			approved = params[:approved]== 'true' ? true : false
			unapproved = params[:unapproved] == 'true' ? true : false
			opened = unapproved = params[:opened] == 'true' ? true : false
			closed = unapproved = params[:closed] == 'true' ? true : false
		else
			approved=params[:approved]
			unapproved=params[:unapproved]
			opened =params[:opened]
			closed = params[:closed]
		end

		if approved == false || unapproved == false
			periods = periods.where('approved = ?', approved)
		end

		if opened == false || closed == false
			periods = periods.where('periods.status = ?', opened == true ? 'opened' : 'closed')
		end

		periods = periods.where('periods.user_id IN (' + ManagerDriver.manager_drivers_ids(user.company, user).join(',') + ')')
		periods = periods.eager_load(:user)
		periods = periods.where("users.tester = FALSE").sort_by { |period| [period.user.last_name, period.user.first_name, period.start_date] }
		periods.each do |p|
			end_date = p.end_date
			end_date = end_date.in_time_zone('London').strftime("%d/%m/%Y %H:%M") if !end_date.nil?
			users.push(p.user_id)
			values.push([p.id, p.user.first_name, p.user.last_name, p.user.email, 
				p.start_date.in_time_zone('London').strftime("%d/%m/%Y %H:%M"), end_date, p.status, p.closed_by, p.approved, p.agent_email, p.business_mileage, p.private_mileage, 
				p.start_mileage, p.end_mileage
			])
		end
		return [columns, values, users]
	end
end

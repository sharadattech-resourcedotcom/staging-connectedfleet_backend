class Reports::HoursPayroll
	def self.info
		return {:name => 'Driver Hours Payroll', :key => 'driver_hours_payroll_detailed'} 
	end


	def self.generate(user, date_from, date_to, params)
		columns = ['Branch', 'First Name', 'Last Name', 'Holiday Pay B/F','Jobs Between 08:00 and 20:00 Monday to Friday', 'Jobs Between 08:00 and 20:00 Monday to Friday - Total',
			'Other Hours Worked - Total', 'Other hours worked', 'Holiday Minutes Accrual', 'Holiday Pay Accrual','Holiday Claimed', 'Paid This Month', 'Holiday Pay C/F', 'Total Hours']
		values = []

		users = ManagerDriver.manager_drivers(user.company, user)
		return [columns, values] if users.length == 0

		if users.length > 0
			users = User.where('users.id IN (' + users.map{|x| x.id}.join(',') + ')  AND users.tester = FALSE')
			users = users.eager_load(:branch)
		end

		users.each do |u|
			payrolls = Payroll.where("user_id = ? AND for_date >= ? AND for_date <= ?", u.id, Date.parse(date_from), Date.parse(date_to))			

			normal_hours = 0
			extra_hours = 0
			payment = 0
			extra_payment = 0
			standard_payment = 0

			payrolls.each do |p|
				if p.normal_hours.nil? || p.standard_payment.nil?
					then next
				end

				normal_hours = normal_hours + p.normal_hours
				extra_hours = extra_hours + p.extra_hours
				standard_payment = standard_payment + p.standard_payment
				extra_payment = extra_payment + p.extra_payment
				payment = payment + (p.standard_payment + p.extra_payment)
			end

			values.push([
				(u.branch.nil?) ? '' : u.branch.description,
				u.first_name,
				u.last_name,
				'0',
				normal_hours.round(2).to_s,
				(normal_hours.round(2) * 7.1).round(2).to_s,
				extra_hours.round(2).to_s,
				(extra_hours.round(2) * 8.25).round(2).to_s,
				((normal_hours.round(2) + extra_hours.round(2)) * 7.26).round(2).to_s,
				((normal_hours.round(2) * 7.1 * 0.1208) + (extra_hours.round(2) * 8.25 * 0.1208)).round(2).to_s,
				'',
				((normal_hours.round(2) * 7.1) + (extra_hours.round(2) * 8.25) + (normal_hours.round(2) * 7.1 * 0.1208) + (extra_hours.round(2) * 8.25 * 0.1208)).round(2).to_s,
				'',
				(normal_hours.round(2) + extra_hours.round(2)).to_s
				# standard_payment,				
				# extra_payment,
			])
		end

		return [columns, values]
	end
end
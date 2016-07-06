class Reports::Core

	def self.list(session_user)
		# Retturn list of reports with date range available
		if session_user.company_id == 6 || session_user.company_id == 34 #EASIDRIVE
			return [
				Reports::NoMileageTrips,
				Reports::AppVersions,
				Reports::ManagersOfDrivers,
				Reports::HoursPayroll
			]
		end

		list = [
			Reports::Trips,
			Reports::Periods,
			Reports::AppVersions,
			Reports::TripsStat,
			Reports::ManagersOfDrivers,
			Reports::DriversOverallSpeed,
			Reports::DriversSpeedRange,
			Reports::TripsSpeed,
			Reports::DriverPayroll,
			Reports::DriverPayrollDetailed,
			Reports::BehaviourReport,
			Reports::TopTenBehaviour,
			Reports::PayrollReport
		]

		if session_user.company.enabled_hours_payroll
			list.push(Reports::HoursPayroll)
		end
		list.push(Reports::Speeding) if session_user.company_id == 4 #PHOTOME

		return list
	end

	def self.info_list(session_user)
		reports = []

		Reports::Core.list(session_user).each do |r| 
			reports.push(r.info)
		end

		return reports
	end

	def self.generate(user, report_name, date_from, date_to, params)
		reports_list = Reports::Core.list(user)

		reports_list.each do |r|
			if r.info()[:key] == report_name
				return r.generate(user, date_from, date_to, params)
			end
		end
		return [[], []]
	end
end
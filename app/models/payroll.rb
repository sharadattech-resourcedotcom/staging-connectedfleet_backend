class Payroll < ActiveRecord::Base
	belongs_to :user
	
	def self.calculate_for(date)
		Payroll.where(:for_date => date).each do |p|
			extra_hours = 0
			start_datetime = p.start_datetime.change(sec: 0)
			end_datetime = p.end_datetime.change(sec: 0)
			
			if start_datetime.hour < 8
				extra_hours = extra_hours + ((start_datetime.change(hour: 8, min: 0) - start_datetime) / 1.hour)
				start_datetime = start_datetime.change(hour: 8, min: 0)
			end

			if end_datetime.hour >= 18
				extra_hours = extra_hours + ((end_datetime - end_datetime.change(hour: 18, min: 0)) / 1.hour)
				end_datetime = end_datetime.change(hour: 18, min: 0)
			end
			normal_hours = ((end_datetime - start_datetime) / 1.hour)
			p.normal_hours = normal_hours
			p.extra_hours = extra_hours
			p.standard_payment = normal_hours * p.user.driver_type.hourly_rate if !p.user.driver_type.nil?
			p.extra_payment =  extra_hours * p.user.driver_type.additional_hour_rate if !p.user.driver_type.nil?
			p.save!
		end
	end
end
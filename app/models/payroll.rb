class Payroll < ActiveRecord::Base
	belongs_to :user
	
	def self.calculate_for(date)
		Payroll.where("DATE(for_date) = DATE(?) AND end_datetime IS NOT NULL", date).each do |p|
			extra_hours = 0
			normal_hours = 0
			start_datetime = p.start_datetime.change(sec: 0)
			end_datetime = p.end_datetime.change(sec: 0)

			if !start_datetime.weekend? && end_datetime.weekend?
				tmp = end_datetime.last_friday.change(hour: 18, min: 0)
				extra_hours = (end_datetime - tmp) / 1.hour
				end_datetime = tmp
			end

			if start_datetime.weekend?
				if end_datetime.weekend?
					extra_hours = (end_datetime - start_datetime) / 1.hour
				else
					tmp = end_datetime.last_sunday.change(hour: 23, min: 59)
					extra_hours = (tmp - end_datetime) / 1.hour
					start_datetime = start_datetime.nearest_monday.change(hour: 0, min: 0)
				end
			end
			
			if !start_datetime.weekend? && !end_datetime.weekend?
				if start_datetime.hour < 8
					extra_hours = extra_hours + ((start_datetime.change(hour: 8, min: 0) - start_datetime) / 1.hour)
					start_datetime = start_datetime.change(hour: 8, min: 0)
				end

				if end_datetime.hour >= 18
					extra_hours = extra_hours + ((end_datetime - end_datetime.change(hour: 18, min: 0)) / 1.hour)
					end_datetime = end_datetime.change(hour: 18, min: 0)
				end
				normal_hours = ((end_datetime - start_datetime) / 1.hour) if (end_datetime - start_datetime) > 0
				p.normal_hours = normal_hours
				p.extra_hours = extra_hours
				p.standard_payment = normal_hours * p.user.driver_type.hourly_rate if !p.user.driver_type.nil?
				p.extra_payment =  extra_hours * p.user.driver_type.additional_hour_rate if !p.user.driver_type.nil?
				p.save!
			end
		end
	end
end

class Time
  def weekend?
    return self.saturday? || self.sunday?
  end

  def last_friday
  	tmp = self
  	until tmp.friday? do
  		tmp = tmp - 1.day
  	end
  	return tmp
  end

  def nearest_monday
  	tmp = self
  	until tmp.monday? do
  		tmp = tmp + 1.day
  	end
  	return tmp
  end

  def last_sunday
  	tmp = self
  	until tmp.sunday? do
  		tmp = tmp - 1.day
  	end
  	return tmp
  end
end

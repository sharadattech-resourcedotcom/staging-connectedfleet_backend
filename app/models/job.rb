class Job < ActiveRecord::Base
	belongs_to :appointment
	belongs_to :user
	has_many :mobileInspections
	
	def driver_full_name
		info = self.user.full_name
		return info
	end

	def appointment_info
		description = self.appointment.branch.description.to_s + ' - ' +self.appointment.product.description.to_s
		id = self.appointment.id.to_s
		vehicle = self.appointment.vehicle_info
		vehicle_id = self.appointment.vehicle.id
		address = self.appointment.postcode.to_s + ', ' +self.appointment.city.to_s + ', ' +self.appointment.street.to_s
		return {:description => description, :id => id, :vehicle => vehicle, :vehicle_id => vehicle_id, :address => address}	
	end

	def as_json(options = { })
	    super((options || { }).merge({
	    	:methods => [:driver_full_name, :appointment_info]
	    }))
  	end
end
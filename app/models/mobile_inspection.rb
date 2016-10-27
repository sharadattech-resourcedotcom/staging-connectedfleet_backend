class MobileInspection < ActiveRecord::Base
	belongs_to :job
	belongs_to :user, class_name: "User"
	belongs_to :vehicle
	has_many :damageItems
	has_many :damage_collections

	def driver_full_name
		info = self.user.full_name
		return info
	end

	def job_number
		return job.number if !job.nil?
		return nil
	end

	def vehicle_info
		info = nil
		info = self.vehicle.make_and_model + ' (' + self.vehicle.registration + ")" if !self.vehicle.nil?
		return info
	end

	def self.company_inspections(company_id, is_sent)
		inspections = MobileInspection.where(:is_sent => is_sent)
		inspections = inspections.select{|i| i.user.company_id == company_id}
		return inspections
	end

	def appointment_id
		return self.job.appointment_id if !self.job.nil?
		return nil
	end

	def email_variables
		return_data = {}
		return_data[:DRIVER_NAME] = self.driver_full_name
		return_data[:VEHICLE_REGISTRATION] = self.vehicle.nil? ? '--' : self.vehicle.registration 
		return_data[:VEHICLE_MANUFACTURER] = self.vehicle.nil? ? '--' : self.vehicle.manufacturer.description
		return_data[:VEHICLE_MODEL] = self.vehicle.nil? ? '--' : self.vehicle.model.description
		return_data[:LOOSE_ITEMS] = self.loose_items
		return_data[:NOTES] = self.notes
		return_data[:QUESTIONS] = self.questions
		return_data[:CONTACT_EMAIL] = self.job.nil? || self.job.appointment.email.nil? || self.job.appointment.contact_name == '' ? 'UNKNOWN' : self.job.appointment.email
		return_data[:CONTACT_NAME] = self.job.nil? || self.job.appointment.contact_name.nil? || self.job.appointment.contact_name == '' ? 'UNKNOWN' : self.job.appointment.contact_name 

    	return return_data
	end

	def inspection_type
		return self.class.name
	end

	def as_json(options = { })
	    super((options || { }).merge({
	    	:include => [:damageItems, :vehicle],
	    	:methods => [:driver_full_name, :damage_collections, :job_number, :vehicle_info, :appointment_id, :inspection_type]
	    }))
  	end
	
end
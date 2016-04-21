class Appointment < ActiveRecord::Base
	belongs_to :comapny
	belongs_to :branch
	belongs_to :product
	belongs_to :insurance_company
	belongs_to :vehicle
	has_one :job, class_name: "Job"
	has_one :collection_job, class_name: "Job"

	validates_presence_of :branch_id, :product_id, :insurance_company_id, :vehicle_id

	def vehicle_info
		info = self.vehicle.make_and_model + ' (' + self.vehicle.registration + ")"
		return info
	end

	def driver_full_name
		info = self.job.user.full_name if !self.job.nil? && !self.job.user.nil?
		return info
	end

	def status
		if self.job.nil?
			return "NO JOB"
		else
			if self.job.status == 0
				return "PENDING"
			elsif self.job.is_done 
				return "COMPLETED"
			else
				return "SCHEDULED"
			end
		end
	end

	def self.by_vehicles_access(user_id)
		return Appointment.where(vehicle_id => UserVehicle.user_vehicles_ids(user_id))
	end

	def self.by_drivers_access(user)
		return Appointment.joins(:job).where('jobs.user_id IN (?)', ManagerDriver.manager_drivers_ids(user.company, user))
	end

	def as_json(options = { })
	    super((options || { }).merge({
	    	:methods => [:vehicle_info, :driver_full_name, :status],
	        :include => [:branch, :product, :insurance_company, :vehicle]
	    }))
  	end
end
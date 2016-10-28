class EstimatorInspection < ActiveRecord::Base
	belongs_to :driver, :class_name => "User"
	belongs_to :vehicle
	has_many :damage_collections
	has_many :damage_items

	def driver_full_name
		info = self.driver.full_name
		return info
	end

	def check_list
		return JSON.parse(super)
	end

	def vehicle_info
		info = nil
		info = self.vehicle.make_and_model + ' (' + self.vehicle.registration + ")" if !self.vehicle.nil?
		return info
	end

	def vehicle_make
		return self.vehicle.manufacturer.description
	end

	def vehicle_model
		return self.vehicle.model.description
	end

	def self.company_inspections(company_id)
		uids = User.where(:company_id => company_id).pluck(:id)
		return self.where("driver_id IN (?)", uids)
	end

	def inspection_type
		return self.class.name
	end

	def as_json(options = { })
	    super((options || { }).merge({
	    	:include => [:damage_items, :vehicle],
	    	:methods => [:driver_full_name, :damage_collections, :vehicle_info, :inspection_type, :vehicle_make, :vehicle_model]
	    }))
  	end
end
class UserVehicle < ActiveRecord::Base
	belongs_to :vehicle
	belongs_to :user

	validates_presence_of :user_id, :vehicle_id

	def self.has_access(user_id, vehicle_id)
		return UserVehicle.where("user_id = ? AND vehicle_id = ?", user_id, vehicle_id).exist?
	end

	def self.user_vehicles_ids(user_id)
		vehicles_ids = []
		UserVehicle.where(:user_id => user_id).each do |uv|
			vehicles_ids.push(uv.vehicle_id)
		end
		return vehicles_ids
	end
end
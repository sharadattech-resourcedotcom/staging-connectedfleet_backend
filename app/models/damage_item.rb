class DamageItem < ActiveRecord::Base
	belongs_to :mobile_inspection
	belongs_to :user

	def damage_collection 
		return DamageCollection.where("mobile_inspection_id = ? AND collection_id = ?", self.mobile_inspection_id, self.collection_id).take
	end
	
end
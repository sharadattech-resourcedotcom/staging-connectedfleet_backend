class DamageCollection < ActiveRecord::Base
	belongs_to :mobile_inspection
	belongs_to :estimator_inspection
	
	def damage_items
		if !self.mobile_inspection_id.nil?
			return DamageItem.where("mobile_inspection_id = ? AND collection_id = ?", self.mobile_inspection_id, self.collection_id)
		elsif !self.estimator_inspection_id.nil?
			return DamageItem.where("estimator_inspection_id = ? AND collection_id = ?", self.estimator_inspection_id, self.collection_id)
		else
			return []
		end
		
	end

	def as_json(options={})
      super(:methods => [:damage_items])
  	end 

  	def to_json(options={})
      super(:methods => [:damage_items])
  	end 
end
class DamageCollection < ActiveRecord::Base
	belongs_to :mobile_inspection
	
	def damage_items
		return DamageItem.where("mobile_inspection_id = ? AND collection_id = ?", self.mobile_inspection_id, self.collection_id)
	end

	def as_json(options={})
      super(:methods => [:damage_items])
  	end 

  	def to_json(options={})
      super(:methods => [:damage_items])
  	end 
end
class Point < ActiveRecord::Base
	self.primary_keys = :user_id, :timestamp

	def fuel_in_mpg
		return -1 if self.fuel_economy == -1
		
 		return sprintf("%.2f", self.fuel_economy * TripStat::KML_TO_MPG).to_f
	end

	def as_json(options = { })
	    super((options || { }).merge({
	    	:methods => [:fuel_in_mpg]
	    }))
  	end
end
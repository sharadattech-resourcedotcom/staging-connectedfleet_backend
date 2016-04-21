class Branch < ActiveRecord::Base
	belongs_to :comapny
	has_many :appointments

	validates_presence_of :company_id, :description
	before_destroy :before_destroy

	def before_destroy
	  return true if appointments.count == 0
	  errors.add :base, "Cannot delete this branch because it is used in at least one appointment"
	  return false
	end
end
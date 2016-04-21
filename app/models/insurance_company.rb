class InsuranceCompany < ActiveRecord::Base
	belongs_to :comapny
	has_many :appointments

	validates_presence_of :company_id, :name
	before_destroy :before_destroy

	def before_destroy
	  return true if appointments.count == 0
	  errors.add :base, "Cannot delete this insurance company because it is used in at least one appointment"
	  false
	end
end
class DisposalPhoto < ActiveRecord::Base
	belongs_to :disposal_inspection
	has_one :user, through: :disposal_inspections
end
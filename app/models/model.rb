class Model < ActiveRecord::Base
	belongs_to :manufacturer

	validates_presence_of :manufacturer_id, :description
end
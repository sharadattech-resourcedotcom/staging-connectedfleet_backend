class Manufacturer < ActiveRecord::Base
	validates_presence_of :description
	has_many :models
end
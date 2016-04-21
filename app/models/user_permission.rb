class UserPermission < ActiveRecord::Base
	belongs_to :permission
	belongs_to :user

	validates_presence_of :user_id, :permission_id
end
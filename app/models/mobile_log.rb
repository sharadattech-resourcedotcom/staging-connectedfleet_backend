class MobileLog < ActiveRecord::Base
  belongs_to :user
  self.primary_keys = :user_id, :date
end

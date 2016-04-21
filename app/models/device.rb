class Device < ActiveRecord::Base
  has_one :token
  belongs_to :user

  def self.create(device, user_id)

    d = Device.new
    d.platform = device[:platform]
    d.os_version = device[:os_version]
    d.device_model = device[:device_model]
    d.user_id = user_id
    d.save
  end
end

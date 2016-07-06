class AddDeviceAndAppInfo < ActiveRecord::Migration
  def change
  	add_column :users, :last_device, :string
  	add_column :api_loggers, :device_model, :string
  	add_column :api_loggers, :app_type, :string
  end
end

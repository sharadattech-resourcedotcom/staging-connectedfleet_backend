class AddVersionCodeToApiLoggers < ActiveRecord::Migration
  def change
  	add_column :api_loggers, :app_version_code, :integer
  end
end

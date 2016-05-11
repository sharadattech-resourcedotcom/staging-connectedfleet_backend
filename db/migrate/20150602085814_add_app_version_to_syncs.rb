class AddAppVersionToSyncs < ActiveRecord::Migration
  def change
  	add_column :api_loggers, :app_version, :string, :default => ''
  end
end

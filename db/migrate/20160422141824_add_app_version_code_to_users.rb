class AddAppVersionCodeToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :app_version_code, :integer
  end
end

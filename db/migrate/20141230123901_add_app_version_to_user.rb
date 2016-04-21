class AddAppVersionToUser < ActiveRecord::Migration
  def change
    add_column :users, :api_version,  :string, :default => ''
  end
end

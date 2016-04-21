class AddLastRequestToUsers < ActiveRecord::Migration
  def change
  		add_column :users, :last_request, :datetime
  end
end

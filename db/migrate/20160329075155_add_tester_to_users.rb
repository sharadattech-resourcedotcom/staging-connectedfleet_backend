class AddTesterToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :tester, :boolean, :default => false
  	User.where("company_id = 4 AND (first_name ILIKE '%test%' OR last_name ILIKE '%test%')").each do |u|
  		u.update_attribute(:tester, true)
  	end
  end
end

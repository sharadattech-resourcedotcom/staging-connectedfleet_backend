class AddMarkerTypeToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :marker_type, :integer, :default => 0

  		#Gary Smith
    User.find(35).update_attribute(:marker_type, 1)
  	ManagerDriver.manager_drivers_hierarchic(Company.find(4), User.find(35)).each do |driver|
  		driver.update_attribute(:marker_type, 1)
  	end
  		#David Stock
    User.find(25).update_attribute(:marker_type, 2) 
  	ManagerDriver.manager_drivers_hierarchic(Company.find(4), User.find(25)).each do |driver|
  		driver.update_attribute(:marker_type, 2)
  	end
  	  	#Stephen Woodbridge
    User.find(79).update_attribute(:marker_type, 3)   
  	ManagerDriver.manager_drivers_hierarchic(Company.find(4), User.find(79)).each do |driver|
  		driver.update_attribute(:marker_type, 3)
  	end
  		#Kevin Nichols
    User.find(49).update_attribute(:marker_type, 4)
  	ManagerDriver.manager_drivers_hierarchic(Company.find(4), User.find(49)).each do |driver|
  		driver.update_attribute(:marker_type, 4)
  	end
		#James McCartney
    User.find(43).update_attribute(:marker_type, 5)
  	ManagerDriver.manager_drivers_hierarchic(Company.find(4), User.find(43)).each do |driver|
  		driver.update_attribute(:marker_type, 5)
  	end
  		#Garry Richardson
    User.find(33).update_attribute(:marker_type, 6)
  	ManagerDriver.manager_drivers_hierarchic(Company.find(4), User.find(33)).each do |driver|
  		driver.update_attribute(:marker_type, 6)
  	end  
  		#Alfred Smith
    User.find(15).update_attribute(:marker_type, 7)
  	ManagerDriver.manager_drivers_hierarchic(Company.find(4), User.find(15)).each do |driver|
  		driver.update_attribute(:marker_type, 7)
  	end 	
  end
end

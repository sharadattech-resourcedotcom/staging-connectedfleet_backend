class AddBusinessPrivateToPeriod < ActiveRecord::Migration
  def change
    add_column :periods, :business_mileage, :integer, :default => 0
    add_column :periods, :private_mileage,  :integer, :default => 0    
  end
end

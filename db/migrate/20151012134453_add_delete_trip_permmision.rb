class AddDeleteTripPermmision < ActiveRecord::Migration
  def change
  	permission = Permission.new
  	permission.description = "delete trips"
  	permission.save!
  end
end

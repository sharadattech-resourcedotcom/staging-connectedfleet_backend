class InsertSeeIsnpectionDetailsPerm < ActiveRecord::Migration
  def change
  	p = Permission.create({:description => 'see inspection details'})
  end
end

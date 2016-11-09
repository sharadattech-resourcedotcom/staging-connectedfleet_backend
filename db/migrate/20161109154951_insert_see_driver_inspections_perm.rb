class InsertSeeDriverInspectionsPerm < ActiveRecord::Migration
  def change
  	p = Permission.create({:description => 'see driver inspections'})
  end
end

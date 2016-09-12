class ChangeAppointmentColumns < ActiveRecord::Migration
  def change
  	change_column :appointments, :branch_id, :integer, :null => true
  	change_column :appointments, :insurance_company_id, :integer, :null => true
  end
end

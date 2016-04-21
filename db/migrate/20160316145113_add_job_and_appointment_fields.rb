class AddJobAndAppointmentFields < ActiveRecord::Migration
  def change
  	add_column :jobs, :job_type, :string, :default => "D"
  	add_column :appointments, :col_postcode, :string
  	add_column :appointments, :col_city, :string
  	add_column :appointments, :col_street, :string
  	add_column :appointments, :col_number, :string
  end
end
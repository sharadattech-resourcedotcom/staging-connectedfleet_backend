class AddGeminiFieldsToAppointment < ActiveRecord::Migration
  def change
  	add_column :mobile_inspections, :insurer, :string
	add_column :mobile_inspections, :vatstatus, :string
	add_column :mobile_inspections, :customername, :string
	add_column :mobile_inspections, :customerphonenumber, :string
	add_column :mobile_inspections, :courtesy_car, :boolean

	add_column :appointments, :insurer, :string
	add_column :appointments, :vatstatus, :string
	add_column :appointments, :customername, :string
	add_column :appointments, :customerphonenumber, :string
	add_column :appointments, :courtesy_car, :boolean
  end
end

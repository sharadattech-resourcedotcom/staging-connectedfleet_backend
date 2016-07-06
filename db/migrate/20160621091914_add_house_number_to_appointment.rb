class AddHouseNumberToAppointment < ActiveRecord::Migration
  def change
  	add_column :appointments, :home_number, :string
  end
end

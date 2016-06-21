class AddStreet2ToAppointment < ActiveRecord::Migration
  def change
  	add_column :appointments, :street2, :string
  end
end

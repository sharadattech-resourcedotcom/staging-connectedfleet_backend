class CreateDriverType < ActiveRecord::Migration
  def change
    create_table :driver_types do |t|
    	t.belongs_to :company
    	t.column :name, :string
    	t.column :hourly_rate, :float
    	t.column :additional_hour_rate, :float 
    end
  end
end

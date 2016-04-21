class AddVehiclesManagementTables < ActiveRecord::Migration
  def change
  	create_table :manufacturers do |t|
    	t.column :description, :string, :null => false 
    end
    create_table :models do |t|
    	t.column :description, :string, :null => false 
    	t.belongs_to :manufacturer, :null => false
    end
    create_table :vehicles do |t|
    	t.belongs_to :manufacturer, :null => false
    	t.belongs_to :model, :null => false
    	t.belongs_to :company, :null => false
    	t.column :registration, :string, :null => false
    	t.column :color, :string
    	t.column :engine, :float
    	t.column :model_year, :integer
    	t.column :transmission, :string
    	t.column :fuel_type, :string 
    end
  end
end

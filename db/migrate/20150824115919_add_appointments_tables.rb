class AddAppointmentsTables < ActiveRecord::Migration
  def change
  	create_table :branches do |t|
    	t.column :description, :string, :null => false 
    	t.belongs_to :company, :null => false
    end

    create_table :products do |t|
    	t.column :description, :string, :null => false 
    	t.belongs_to :company, :null => false
    end

    create_table :insurance_companies do |t|
    	t.column :name, :string, :null => false
    	t.belongs_to :company, :null => false 
    end

    create_table :appointments do |t|
    	t.belongs_to :branch, :null => false
    	t.belongs_to :product, :null => false
    	t.belongs_to :company, :null => false
    	t.belongs_to :insurance_company
    	t.belongs_to :vehicle, :null => false
        t.column :job_reference, :string
    	t.column :claim_number, :integer
    	t.column :excess, :string 
    	t.column :contact_name, :string
    	t.column :email, :string
    	t.column :street, :string
    	t.column :city, :string 
    	t.column :postcode, :string
    	t.column :mobile, :string
    	t.column :home_phone, :string
    	t.column :work_phone, :string
    	t.column :notes, :string
    	t.timestamps 
    end

    add_foreign_key(:appointments, :branches, column: 'branch_id')
    add_foreign_key(:appointments, :products, column: 'product_id')
    add_foreign_key(:appointments, :companies, column: 'company_id')
    add_foreign_key(:appointments, :insurance_companies, column: 'insurance_company_id')
    add_foreign_key(:appointments, :vehicles, column: 'vehicle_id')
    add_foreign_key(:branches, :companies, column: 'company_id')
    add_foreign_key(:products, :companies, column: 'company_id')
    add_foreign_key(:insurance_companies, :companies, column: 'company_id')
  end
end

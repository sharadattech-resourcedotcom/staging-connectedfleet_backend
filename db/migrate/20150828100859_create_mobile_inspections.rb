class CreateMobileInspections < ActiveRecord::Migration
  def change
    create_table :mobile_inspections do |t|
    	t.belongs_to :job
    	t.belongs_to :user
    	t.column :loose_items, :string
    	t.column :questions, :string
    	t.column :terms_file_name, :string
    	t.column :local_id, :integer
    	t.timestamps
    end
    add_foreign_key(:mobile_inspections, :jobs, column: 'job_id')
    add_foreign_key(:mobile_inspections, :users, column: 'user_id')
  end
end

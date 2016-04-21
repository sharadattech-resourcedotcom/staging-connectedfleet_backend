class CreateJobs < ActiveRecord::Migration
  def change
    create_table :jobs do |t|
    	t.belongs_to :user
    	t.belongs_to :appointment, :null => false
    	t.column :start_date, :datetime
        t.column :end_date, :datetime
    	t.column :status, :integer
        t.column :instructions, :string
        t.column :is_acknowledged, :boolean
        t.column :number, :string
        t.column :abort_code, :string
    end
    
    add_column :trips, :job_id, :integer
    
    add_foreign_key(:trips, :jobs, column: 'job_id')
    add_foreign_key(:jobs, :appointments, column: 'appointment_id')
	add_foreign_key(:jobs, :users, column: 'user_id')
  end
end

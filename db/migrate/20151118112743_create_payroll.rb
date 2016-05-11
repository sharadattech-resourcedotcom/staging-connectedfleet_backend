class CreatePayroll < ActiveRecord::Migration
  def change
    create_table :payrolls do |t|
    	t.belongs_to :user
    	t.column :for_date,  :date
		t.column :start_datetime,  :datetime
		t.column :end_datetime,  :datetime
		t.column :extra_hours, :float
		t.column :normal_hours, :float
		t.column :standard_payment, :float
		t.column :extra_payment, :float
    end
  end
end

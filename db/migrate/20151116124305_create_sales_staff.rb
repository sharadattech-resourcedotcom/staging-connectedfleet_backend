class CreateSalesStaff < ActiveRecord::Migration
  def change
    create_table :sales_staffs do |t|
    	t.belongs_to :user
    	t.belongs_to :company
    end
  end
end

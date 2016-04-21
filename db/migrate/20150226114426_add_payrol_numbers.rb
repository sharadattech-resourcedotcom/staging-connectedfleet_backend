class AddPayrolNumbers < ActiveRecord::Migration
  def change
  	add_column :users, :payroll_number, :string, :default => ""
  end
end
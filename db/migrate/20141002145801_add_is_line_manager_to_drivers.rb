class AddIsLineManagerToDrivers < ActiveRecord::Migration
  def change
    add_column :users, :is_line_manager, :bool, :default => false
    add_column :users, :is_payroll_excluded, :bool, :default => false
  end
end

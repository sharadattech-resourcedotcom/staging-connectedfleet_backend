class AddEnabledHoursPayrollToCompanies < ActiveRecord::Migration
  def change
  	add_column :companies, :enabled_hours_payroll, :boolean, :default => false
  end
end

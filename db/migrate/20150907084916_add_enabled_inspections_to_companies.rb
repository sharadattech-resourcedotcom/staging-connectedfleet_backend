class AddEnabledInspectionsToCompanies < ActiveRecord::Migration
  def change
  	add_column :companies, :enabled_inspections, :boolean, :default => false
  end
end

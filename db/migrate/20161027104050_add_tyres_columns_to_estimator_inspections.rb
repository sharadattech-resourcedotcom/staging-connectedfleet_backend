class AddTyresColumnsToEstimatorInspections < ActiveRecord::Migration
  def change
  	add_column :estimator_inspections, :ply_lining_condition, :string
  	add_column :estimator_inspections, :nsf, :integer
  	add_column :estimator_inspections, :nsr, :integer
  	add_column :estimator_inspections, :osf, :integer
  	add_column :estimator_inspections, :osr, :integer
  end
end

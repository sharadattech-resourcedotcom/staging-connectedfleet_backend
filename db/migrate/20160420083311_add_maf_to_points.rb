class AddMafToPoints < ActiveRecord::Migration
  def change
  	add_column :points, :maf, :integer
  	add_column :points, :engine_coolant, :integer
  end
end
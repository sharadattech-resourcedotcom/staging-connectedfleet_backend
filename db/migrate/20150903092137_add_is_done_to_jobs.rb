class AddIsDoneToJobs < ActiveRecord::Migration
  def change
  	add_column :jobs, :is_done, :boolean, :default => false
  end
end

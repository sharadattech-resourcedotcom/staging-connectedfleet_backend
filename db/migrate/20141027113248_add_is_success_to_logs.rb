class AddIsSuccessToLogs < ActiveRecord::Migration
  def change
    add_column :api_loggers, :succeeded,  :integer, :default => 0    
  end
end

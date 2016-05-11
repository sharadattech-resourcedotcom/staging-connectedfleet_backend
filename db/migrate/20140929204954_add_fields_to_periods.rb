class AddFieldsToPeriods < ActiveRecord::Migration
  def change
    add_column :periods, :closed_by, :string, :null => true
    add_column :periods, :approved,  :boolean
    add_column :periods, :reminder_status,  :string    
  end
end

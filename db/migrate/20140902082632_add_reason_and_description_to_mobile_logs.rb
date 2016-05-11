class AddReasonAndDescriptionToMobileLogs < ActiveRecord::Migration
  def change
    add_column :mobile_logs, :reason, :text, :null => false, :default => 'Unknown'
    add_column :mobile_logs, :description, :text
  end
end

class CreateDisposalInspections < ActiveRecord::Migration
  def change
    create_table :disposal_inspections do |t|
    	t.timestamps
    	t.belongs_to :user
    	t.string :vehicle_registration
    	t.timestamp :inspection_timestamp
    	t.boolean :all_sent, :default => false
    	t.integer :local_id
    end
  end
end

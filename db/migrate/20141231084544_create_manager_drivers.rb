class CreateManagerDrivers < ActiveRecord::Migration
  def change
    create_table :manager_drivers do |t|
      t.column :manager_id, :integer, :null => false
      t.column :driver_id, :integer, :null => false
      t.timestamps
    end
  end
end

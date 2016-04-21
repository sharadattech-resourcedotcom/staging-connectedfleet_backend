class CreateDevices < ActiveRecord::Migration
  def change
    create_table :devices do |t|
      t.string :platform, :limit => 20
      t.string :os_version, :limit => 20
      t.string :device_model, :limit =>20
      t.belongs_to :user, :null =>false
    end
  end
end

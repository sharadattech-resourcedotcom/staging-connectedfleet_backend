class AddIndexToDevices < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        execute <<-SQL
        ALTER TABLE devices ADD CONSTRAINT fk_devices_users FOREIGN KEY (user_id) REFERENCES users(id)
        SQL
      end

      dir.down do
        execute <<-SQL
        ALTER TABLE devices DROP FOREIGN KEY fk_devices_users
        SQL
      end
    end
  end
end

class AddIndexToTokens < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        execute <<-SQL
        ALTER TABLE tokens ADD CONSTRAINT fk_tokens_users FOREIGN KEY (user_id) REFERENCES users(id)
        SQL
        execute <<-SQL
        ALTER TABLE tokens ADD CONSTRAINT fk_tokens_devices FOREIGN KEY (device_id) REFERENCES devices(id)
        SQL
      end

      dir.down do
        execute <<-SQL
        ALTER TABLE tokens DROP FOREIGN KEY fk_tokens_users
        SQL
        execute <<-SQL
        ALTER TABLE tokens DROP FOREIGN KEY fk_tokens_devices
        SQL
      end
    end
  end
end

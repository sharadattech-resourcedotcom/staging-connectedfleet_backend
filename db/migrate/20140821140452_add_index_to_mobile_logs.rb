class AddIndexToMobileLogs < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        execute <<-SQL
        ALTER TABLE mobile_logs ADD CONSTRAINT fk_mobile_logs_users FOREIGN KEY (user_id) REFERENCES users(id)
        SQL
      end

      dir.down do
        execute <<-SQL
        ALTER TABLE mobile_logs DROP FOREIGN KEY fk_mobile_logs_users
        SQL
      end
    end
  end
end

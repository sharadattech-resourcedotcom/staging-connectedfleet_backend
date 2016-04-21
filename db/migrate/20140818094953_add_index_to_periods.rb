class AddIndexToPeriods < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        execute <<-SQL
        ALTER TABLE periods ADD CONSTRAINT fk_periods_users FOREIGN KEY (user_id) REFERENCES users(id)
        SQL
      end

      dir.down do
        execute <<-SQL
        ALTER TABLE periods DROP FOREIGN KEY fk_periods_users
        SQL
      end
    end
  end
end
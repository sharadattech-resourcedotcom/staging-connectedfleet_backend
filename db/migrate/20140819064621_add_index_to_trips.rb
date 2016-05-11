class AddIndexToTrips < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        execute <<-SQL
        ALTER TABLE trips ADD CONSTRAINT fk_trips_users FOREIGN KEY (user_id) REFERENCES users(id)
        SQL
        execute <<-SQL
        ALTER TABLE trips ADD CONSTRAINT fk_trips_periods FOREIGN KEY (user_id,period_start_date) REFERENCES periods(user_id, start_date)
        SQL
      end

      dir.down do
        execute <<-SQL
        ALTER TABLE trips DROP FOREIGN KEY fk_trips_users
        SQL
        execute <<-SQL
        ALTER TABLE trips DROP FOREIGN KEY fk_trips_periods
        SQL
      end
    end
  end
end
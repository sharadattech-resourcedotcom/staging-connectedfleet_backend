class AddIndexToPoints < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        execute <<-SQL
        ALTER TABLE points ADD CONSTRAINT fk_points_users FOREIGN KEY (user_id) REFERENCES users(id)
        SQL
        execute <<-SQL
        ALTER TABLE points ADD CONSTRAINT fk_points_trips FOREIGN KEY (trip_id) REFERENCES trips(id)
        SQL
      end

      dir.down do
        execute <<-SQL
        ALTER TABLE points DROP FOREIGN KEY fk_points_users
        SQL
        execute <<-SQL
        ALTER TABLE points DROP FOREIGN KEY fk_points_trips
        SQL
      end
    end
  end
end

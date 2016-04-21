class CreatePeriods < ActiveRecord::Migration
  def change
    create_table :periods, :id => false do |t|
      t.belongs_to :user, :null =>false
      t.column :start_date, :timestamp, :null => false
      t.column :end_date, :timestamp
      t.string :status, :limit =>10
    end
    execute "ALTER TABLE periods ADD PRIMARY KEY (user_id, start_date);"
  end
end

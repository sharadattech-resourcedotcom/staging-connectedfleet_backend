class CreateMobileLogs < ActiveRecord::Migration
  def change
    create_table :mobile_logs, :id => false do  |t|
      t.belongs_to :user, :null =>false
      t.column :date, :timestamp, :null => false
      t.text :filename, :null => false
    end
    execute "ALTER TABLE mobile_logs ADD PRIMARY KEY (user_id,date);"
  end
end

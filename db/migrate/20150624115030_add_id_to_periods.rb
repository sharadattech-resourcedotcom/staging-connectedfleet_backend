class AddIdToPeriods < ActiveRecord::Migration
  def change
  	execute 'CREATE SEQUENCE periods_id_seq'
    add_column :periods, :period_id, :integer
    execute "ALTER TABLE periods ALTER COLUMN period_id SET DEFAULT nextval('periods_id_seq')"
    execute "UPDATE periods SET period_id = nextval('periods_id_seq');"
  end
end

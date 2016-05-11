class CreateServerApiVersions < ActiveRecord::Migration
  def change
    create_table :server_api_versions, :id => false do |t|
      t.column :timestamp, :timestamp, :null => false
      t.column :version, :real, :null =>false
    end
    execute 'alter table server_api_versions alter column timestamp set default now()'
    execute 'ALTER TABLE server_api_versions ADD PRIMARY KEY (version);'
    end
end
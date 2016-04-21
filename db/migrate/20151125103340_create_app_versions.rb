class CreateAppVersions < ActiveRecord::Migration
  def change
    create_table :app_versions do |t|
    	t.belongs_to :company
    	t.column :version_name, :float
    	t.column :version_code, :integer
    	t.column :comment, :text
    	t.column :file_path, :string
    	t.column :internal_group, :boolean, :default => false
    end

    add_column :users, :internal_staff, :boolean, :default => false
  end
end

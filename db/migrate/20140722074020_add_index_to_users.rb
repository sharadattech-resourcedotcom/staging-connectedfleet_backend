class AddIndexToUsers < ActiveRecord::Migration
  def change
    
    reversible do |dir|
      dir.up do
        execute <<-SQL
        ALTER TABLE users ADD CONSTRAINT fk_users_companies FOREIGN KEY (company_id) REFERENCES companies(id)
        SQL
      end
      
      dir.down do 
        execute <<-SQL
        ALTER TABLE users DROP FOREIGN KEY fk_users_companies
        SQL
      end      
    end
    
  end
end
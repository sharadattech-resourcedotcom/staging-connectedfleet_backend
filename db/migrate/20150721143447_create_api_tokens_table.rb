class CreateApiTokensTable < ActiveRecord::Migration
  def change
    create_table :api_tokens do |t|
    	t.column :access_token, :string
    	t.column :refresh_token, :string
    	t.belongs_to :user, :null => false  
    end
  end
end

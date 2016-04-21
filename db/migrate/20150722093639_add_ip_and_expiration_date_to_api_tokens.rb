class AddIpAndExpirationDateToApiTokens < ActiveRecord::Migration
  def change
  	add_column :api_tokens, :expiration_date, :timestamp
  	add_column :api_tokens, :ip_address, :string
  end
end

class AddTokenToPeriods < ActiveRecord::Migration
  def change
  	add_column :periods, :approve_token, :string, :default => ''
  end
end

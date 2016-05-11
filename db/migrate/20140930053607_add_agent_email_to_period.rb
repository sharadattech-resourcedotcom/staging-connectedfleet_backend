class AddAgentEmailToPeriod < ActiveRecord::Migration
  def change
    add_column :periods, :agent_email, :string
  end
end

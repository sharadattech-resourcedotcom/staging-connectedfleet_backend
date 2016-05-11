class AddToPeriodsStatusNotNull < ActiveRecord::Migration
  def change
    change_column :periods, :status, :string, :limit =>10, :null => false
  end
end

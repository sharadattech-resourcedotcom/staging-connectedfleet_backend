class AddBranchToDriver < ActiveRecord::Migration
  def change
  	add_column :users, :branch_id, :integer
  	add_foreign_key(:users, :branches, column: 'branch_id')
  end
end

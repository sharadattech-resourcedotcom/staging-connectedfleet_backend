class CreateSettings < ActiveRecord::Migration
  def change
    create_table :settings do |t|
      t.column :red_line_value, :integer
      t.column :orange_line_value, :integer
      t.belongs_to :company, :null => false

      t.timestamps
    end
  end
end

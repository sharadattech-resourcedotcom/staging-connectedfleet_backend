class CreateApiLoggers < ActiveRecord::Migration
  def change
    create_table :api_loggers do |t|
      t.column :type, :string
      t.column :input_val, :text
      t.column :output_val, :text
      
      t.belongs_to :user
      
      t.timestamps
    end
  end
end

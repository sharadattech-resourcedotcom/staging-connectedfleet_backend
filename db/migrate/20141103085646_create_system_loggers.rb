class CreateSystemLoggers < ActiveRecord::Migration
  def change
    create_table :system_loggers do |t|
      t.integer :connected_id
      t.string  :event_type
      t.string  :description
      t.text    :old_value
      t.text    :new_value
      t.belongs_to :user, :null => true
      t.timestamps
    end
  end
end

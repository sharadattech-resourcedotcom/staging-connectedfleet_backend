class AddDisposalInspForeignKeys < ActiveRecord::Migration
  def change
  	  add_foreign_key(:disposal_photos, :disposal_inspections, column: 'disposal_inspection_id')
  end
end

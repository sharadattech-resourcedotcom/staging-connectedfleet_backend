class VehicleForeign < ActiveRecord::Migration
  def change
  	add_foreign_key(:vehicles, :models, column: 'model_id')
  end
end

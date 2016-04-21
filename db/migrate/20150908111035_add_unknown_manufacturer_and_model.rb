class AddUnknownManufacturerAndModel < ActiveRecord::Migration
  def change
  	man = Manufacturer.new(:description => "Unknown")
	man.save!
	mod = Model.new(:description => "Unknown")
	mod.manufacturer = man
	mod.save!
  end
end

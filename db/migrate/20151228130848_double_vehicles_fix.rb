class DoubleVehiclesFix < ActiveRecord::Migration
  REGISTRATION_REGEX = /^[A-Z0-9]*$/
  def change	
    Vehicle.all.each do |v|
        if REGISTRATION_REGEX.match(v.registration).nil?
            v.fix_vehicle
        end
    end

    Trip.where("start_date > '2015-11-28' AND status = 'finished'").each do |t|
    	t.check_vehicle
    end
  end
end

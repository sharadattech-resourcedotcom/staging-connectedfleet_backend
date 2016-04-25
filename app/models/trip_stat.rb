 class TripStat < ActiveRecord::Base
	KML_TO_MPG = 2.35214583
    KM_TO_MPH = 0.625

	belongs_to :trip

 	def fuel_avg_in_mpg
 		return sprintf("%.2f", self.fuel_avg).to_f
 	end

    def self.cron_job(limit, gen)
    	TripStat.transaction do
	    	trips = Trip.where("stats_gen = ? AND trips.status = ?", gen, 'finished').order('trips.id DESC').limit(limit)
	    	trips = trips.eager_load(:user => :company)

	    	unless trips.nil?
		    	trips.each do |t|
		    		TripStat.calc_stat(t)
		    	end
		    end
		end
    end

    def self.remove_outliers(array)
        while true
            max = array.max
            tmp_array = array - [max]
            max = max.to_f
            tmp_max = tmp_array.max.to_f
            if max < 50 || max - tmp_max < 10 
                 return array
            end
            puts max, tmp_max
            puts tmp_max/max
            if tmp_max/max < 0.8
                array = tmp_array
            else
                return array
            end
        end
    end
    
    def self.calc_stat(t)
    	settings = t.user.company.settings
    	stat = TripStat.find_or_create_by(:trip_id => t.id)
    	points = Point.where("trip_id = ?", t.id)
    	dongles = points.select{|x| x.dongle == 1}

    	stat.update_attribute(:dongle_points, dongles.length)
    	stat.update_attribute(:points_total, points.length)

        speeds_over_123 = 0
        speeds_over_123_long = 0
    	speeds = []
    	rpms = []
    	fuels = [] 
        accs = []   	    	
        time = 0
        over = false
        points.each do |d|
            if d.vehicle_speed > 123 && d.vehicle_speed != 152
                speeds_over_123 += 1
                if !over
                    over = true
                    time = d.timestamp
                end
            else 
                if over 
                    over = false
                    if (d.timestamp - time) >= 30
                        speeds_over_123_long += 1
                    end
                end
            end
        end

    	dongles.each do |d|
    		b_points = 0

    		speeds.push(d.vehicle_speed) if d.vehicle_speed >= 0 && d.vehicle_speed != 152  		
            accs.push(d.acceleration) if d.acceleration >= 0

    		if d.fuel_economy >= 0 && d.fuel_economy != 2.5
    			fuels.push(d.fuel_economy)
                diff = settings.fuel_limit - (d.fuel_economy * TripStat::KML_TO_MPG)

                if diff >= 0
                    b_points = b_points + diff * settings.fuel_points
                end
    		end

    		if d.rpm >= 0
    			rpms.push(d.rpm)
    			b_points = b_points + (((d.rpm - settings.rpm_limit) / 100) * settings.rpm_points) if d.rpm > settings.rpm_limit
    		end

    		puts d.fuel_economy.to_s + ',' + d.rpm.to_s + ',' + b_points.to_s
    		d.behaviour_points = sprintf("%.2f", b_points)
    		d.save!
    	end

        trip_beh = dongles.map{|x| x.behaviour_points}.reduce(:+)
        speeds = TripStat.remove_outliers(speeds)
    	stat.update_attributes(
    		:ratio => stat.dongle_points.to_f / stat.points_total.to_f * 100,
    		:bt_ratio => points.select{|x| x.bt == 1}.length / stat.points_total.to_f * 100,
			:speed_min => (speeds.length == 0) ? 0 : speeds.min, 
			:speed_max => (speeds.length == 0) ? 0 : speeds.max, 
			:speed_avg => (speeds.length == 0) ? 0 : speeds.reduce(:+) / speeds.length,
            :acc_avg => (accs.length == 0) ? 0 : sprintf("%.2f", accs.reduce(:+) / accs.length),
			:rpm_avg => (rpms.length == 0) ? 0 : sprintf("%.2f", rpms.reduce(:+) / rpms.length),
			:fuel_avg => (fuels.length == 0) ? 0 : sprintf("%.2f", (fuels.reduce(:+) / fuels.length) * TripStat::KML_TO_MPG),
			:behaviour_points => (trip_beh.nil?) ? 0 : sprintf("%.2f", trip_beh),
            :speeds_over_123 => speeds_over_123,
            :speeds_over_123_long => speeds_over_123_long
		)    	
		
		t.update_attribute(:stats_gen, true)
		t.calculate_mileages
		t.geocode_start_end_location
    end

    # Get chart data
    #
    # Time_fraction - in seconds
    #
    def chart_data(params)
        time_fraction = params[:fraction] * 60
        seconds = 0
        points = Point.where(:trip_id => self.trip_id).order('timestamp asc')
        labels = []
        data = []
        series = []

        return nil if points.length == 0
        
        fuel = []
        fuel_temp = []
        speed = []
        speed_temp = []
        rpm = []
        rpm_temp = []

        start_timestamp = points.first.timestamp.to_i

        points.each do |p|
            diff = p.timestamp.to_i - start_timestamp

            if diff >= time_fraction
                labels.push(Time.at(seconds).utc.strftime("%H:%M"))
                start_timestamp = p.timestamp.to_i

                (fuel_temp.length == 0) ? fuel.push(0) : fuel.push(sprintf("%.2f", (fuel_temp.reduce(:+)) / fuel_temp.length))
                (speed_temp.length == 0) ? speed.push(0) : speed.push(sprintf("%.2f", (speed_temp.reduce(:+)) / speed_temp.length))
                (rpm_temp.length == 0) ? rpm.push(0) : rpm.push(sprintf("%.2f", (rpm_temp.reduce(:+)) / rpm_temp.length))
                
                fuel_temp = []
                speed_temp = []
                rpm_temp = []

                seconds = seconds + time_fraction
            end

            if p.fuel_economy >= 0
                fuel_temp.push(p.fuel_economy * TripStat::KML_TO_MPG)
            end
            if p.vehicle_speed >= 0
                speed_temp.push(p.vehicle_speed * TripStat::KM_TO_MPH)
            end
            if p.rpm >= 0
                rpm_temp.push(p.rpm)
            end
        end

        if params[:fuel] == true
            data.push(fuel)
            series.push('Fuel [mpg]')
        end

        if params[:speed] == true
            data.push(speed)
            series.push('Speed [mph]')
        end

        if params[:rpm] == true
            data.push(rpm)
            series.push('RPM [rpm]')
        end

        return {
            :labels => labels,
            :data => data,
            :series => series
        }
    end

	def as_json(options = { })
	    super((options || { }).merge({
	    	:methods => [:fuel_avg_in_mpg]
	    }))
  	end
end

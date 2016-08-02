class RescueDbService
	require 'net/http'
    require 'uri'

	def self.database_crawler
    	host = "http://46.17.215.204:50001"
    	companies = self.companies
    	# company = companies.select{|c| c[:name] == "LCVR"}.first
    	companies.each do |company|
    		begin
    			puts company
    			puts "VVVVVVVVVVVVVVVVVVVVVVVVVV  #{company[:name]}  VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV"
	    		dir = File.join(Rails.root, company[:name].gsub(" ",""))
				FileUtils.mkdir_p(dir) unless File.directory?(dir)
				puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>#{company[:name]} - SETTINGS<<<<<<<<<<<<<<<<<<<<<<<<<<<"
				data = self.get(URI.join(host, "/fetch_settings_data"), company[:token])
				File.open(File.join(Rails.root, company[:name].gsub(" ",""), 'settings.json'), "wb") { |f| f.write(data.to_json) }
				puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>#{company[:name]} - DRIVER MANAGERS<<<<<<<<<<<<<<<<<<<<<<<<<<<"
				data = self.get(URI.join(host, "/fetch_managers_and_drivers"), company[:token])
				File.open(File.join(Rails.root, company[:name].gsub(" ",""), 'managers.json'), "wb") { |f| f.write(data.to_json) }
				puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>#{company[:name]} - VEHICLES ACCESS<<<<<<<<<<<<<<<<<<<<<<<<<<<"
				data = self.get(URI.join(host, "/management_panel/vehicles_access_users"), company[:token])
				File.open(File.join(Rails.root, company[:name].gsub(" ",""), 'users_managers.json'), "wb") { |f| f.write(data.to_json) }
				puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>#{company[:name]} - USERS<<<<<<<<<<<<<<<<<<<<<<<<<<<"
				data = self.get(URI.join(host, "/fetch_permissions_data"), company[:token])
				users = data["users"]
				File.open(File.join(Rails.root, company[:name].gsub(" ",""), 'users.json'), "wb") { |f| f.write(data["users"].to_json) }
				puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>#{company[:name]} - VEHICLES<<<<<<<<<<<<<<<<<<<<<<<<<<<"
				page = 1
				data = self.post(URI.join(host, "/vehicles/list"), {:search => {}, :page => page}, company[:token])
				vehicles = data["vehicles"]
				size = data["count"]
				while page*100 < size do 
					page += 1
					data = self.post(URI.join(host, "/vehicles/list"), {:search => {}, :page => page}, company[:token])
					vehicles += data["vehicles"]
				end
				File.open(File.join(Rails.root, company[:name].gsub(" ",""), 'vehicles.json'), "wb") { |f| f.write(vehicles.to_json) }
				puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>#{company[:name]} - DRIVER TYPES<<<<<<<<<<<<<<<<<<<<<<<<<<<"
				data = self.get(URI.join(host, "/hours_payroll/fetch_drivers_types"), company[:token])
				File.open(File.join(Rails.root, company[:name].gsub(" ",""), 'driver_types.json'), "wb") { |f| f.write(data.to_json) }
				puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>#{company[:name]} - USERS LAT, LNG, MARKERS<<<<<<<<<<<<<<<<<<<<<<<<<<<"
				data = self.get(URI.join(host, "/autoview/drivers"), company[:token])
				File.open(File.join(Rails.root, company[:name].gsub(" ",""), 'users_lat_lng_marker.json'), "wb") { |f| f.write(data.to_json) }
				puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>#{company[:name]} - VEHICLES PRE DATA<<<<<<<<<<<<<<<<<<<<<<<<<<<"
				data = self.get(URI.join(host, "/vehicles/pre_data"), company[:token])
				File.open(File.join(Rails.root, company[:name].gsub(" ",""), 'vehicles_pre_data.json'), "wb") { |f| f.write(data.to_json) }
			rescue => ex
		    		puts "***************************GENERAL DATA ERROR*******************"
		    		puts ex.message
	        		puts ex.backtrace.select { |x| x.match(/#{Rails.root.join('app')}/) }
	        		# continue
	    	end

			if company[:enabled_inspections]
				puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>#{company[:name]} - APPOINTMENTS<<<<<<<<<<<<<<<<<<<<<<<<<<<"
				page = 1
				data = self.post(URI.join(host, "/appointments/list"), {:search => {}, :page => page}, company[:token])
				appointments = data["appointments"]
				size = data["count"]
				while page*100 < size do 
					page += 1
					data = self.post(URI.join(host, "/appointments/list"), {:search => {}, :page => page}, company[:token])
					appointments += data["appointments"]
				end
				File.open(File.join(Rails.root, company[:name].gsub(" ",""), 'appointments.json'), "wb") { |f| f.write(appointments.to_json) }
				jobs = []
				puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>#{company[:name]} - JOBS, INSPECTIONS<<<<<<<<<<<<<<<<<<<<<<<<<<<"
				(Date.parse("01-01-2016")..Date.today).each do |date|
					begin
						data = self.post(URI.join(host, "/scheduler/fetch_data_for_date"), {:date => date}, company[:token])
						jobs += data["jobs"]
					rescue => ex
			    		puts "**************************************"
			    		puts "date: " + date.to_s
			    		puts ex.message
		        		puts ex.backtrace.select { |x| x.match(/#{Rails.root.join('app')}/) }
		        		next
		    		end
				end
				File.open(File.join(Rails.root, company[:name].gsub(" ",""), 'jobs.json'), "wb") { |f| f.write(jobs.uniq.to_json) }

				data = self.post(URI.join(host, "/inspections/list"), {}, company[:token])
				File.open(File.join(Rails.root, company[:name].gsub(" ",""), 'inspections.json'), "wb") { |f| f.write(data["inspections"].to_json) }
			end	

			dir = File.join(Rails.root, company[:name].gsub(" ",""), "users_periods")
			FileUtils.mkdir_p(dir) unless File.directory?(dir)
			puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>#{company[:name]} - PERIODS<<<<<<<<<<<<<<<<<<<<<<<<<<<"
			users.each do |user|
				begin
					if !user["permissions"].select{|p| p["description"] == "work as driver"}.empty?
						periods = []
						data = self.post(URI.join(host, "/drivers/getCurrentPeriod"), {:driver_id => user["id"]}, company[:token])
						periods.push(data['period'])
						data = self.post(URI.join(host, "/drivers/getClosedPeriods"), {:driver_id => user["id"]}, company[:token])
						periods += data['periods']
						File.open(File.join(Rails.root, company[:name].gsub(" ",""),  "users_periods","#{user["id"]}.json"), "wb") { |f| f.write(periods.to_json) }
					end
				rescue => ex
		    		puts "**************************************"
		    		puts "user_id: " + user["id"].to_s
		    		puts ex.message
	        		puts ex.backtrace.select { |x| x.match(/#{Rails.root.join('app')}/) }
	        		next
	    		end
			end
    	end
    	company = companies.first
    	
    	dir = File.join(Rails.root, "trips_data")
    	FileUtils.mkdir_p(dir) unless File.directory?(dir)
    	puts ">>>>>>>>>>>>>>>>>>>>>>>TRIPS<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
    	(67800..92812).each do |trip_id|
    		begin
	    		data = self.post(URI.join(host, "/trips/details"), {:id => trip_id}, company[:token])
	    		points = self.post(URI.join(host, "/trips/listPoints"), {:id => trip_id}, company[:token]) 
	    		data["trip"]["points"] = points["points"]
	    		data["trip"]["stats"] = data["stats"]
	    		File.open(File.join(Rails.root, "trips_data", "#{data["trip"]["id"]}.json"), "wb") { |f| f.write(data["trip"].to_json) }
	    	rescue => ex
	    		puts "**************************************"
	    		puts "trip_id: " + trip_id.to_s
	    		puts ex.message
        		puts ex.backtrace.select { |x| x.match(/#{Rails.root.join('app')}/) }
        		next

	    	end
    	end
	end

	def self.post(uri, params, token)
		headers = {"Content-Type" => "application/json", 'X-Access-Token' => token}
		http = Net::HTTP.new(uri.host,uri.port)
		request = Net::HTTP::Post.new(uri.path)
		request.add_field("Content-Type", "application/json")
		request.add_field('X-Access-Token', token)
		request.body = params.to_json
		response = http.request(request)
		return JSON.parse(response.body)["data"]
	end

	def self.get(uri, token)
		headers = {"Content-Type" => "application/json", 'X-Access-Token' => token}
		http = Net::HTTP.new(uri.host,uri.port)
		request = Net::HTTP::Get.new(uri.path)
		request.add_field("Content-Type", "application/json")
		request.add_field('X-Access-Token', token)
		response = http.request(request)
		return JSON.parse(response.body)["data"]
	end

	def self.companies
		return [
				# {
		  #       "id": 34,
		  #       "token": "0d605034c410fb4222edf5fa4707c4c6171fe930",
		  #       "name": "EasiDrive",
		  #       "address": "address",
		  #       "phone": "000",
		  #       "enabled_inspections": true,
		  #       "enabled_hours_payroll": true
		  #     },
		  #   		      {
		  #       "id": 9,
		  #       "token": "c3e5c651b67b5101a49cb0400530abd870cf1ba1",
		  #       "name": "Ageas",
		  #       "address": "-",
		  #       "phone": "-",
		  #       "enabled_inspections": true,
		  #       "enabled_hours_payroll": false
		  #     },
		  #     {
		  #       "id": 3,
		  #       "token": "f9bb150a0ca3aee8b4f54730f8dd89fc18c39a6d",
		  #       "name": "CLM",
		  #       "address": "London",
		  #       "phone": "252525",
		  #       "enabled_inspections": true,
		  #       "enabled_hours_payroll": false
		  #     },
		  #     {
		  #       "id": 35,
		  #       "token": "20ca5fd6cce64931313af985d83af4481c71b1f7",
		  #       "name": "Gemini",
		  #       "address": "n/a",
		  #       "phone": "n/a",
		  #       "enabled_inspections": true,
		  #       "enabled_hours_payroll": false
		  #     },
		  #     {
		  #       "id": 13,
		  #       "token": "7111e227bc0ca01160536bcbd4466a83d5e296eb",
		  #       "name": "LCVR",
		  #       "address": ".",
		  #       "phone": ".",
		  #       "enabled_inspections": true,
		  #       "enabled_hours_payroll": false
		  #     },
		  #     {
		  #       "id": 4,
		  #       "token": "ad6661f0c1518c8a9769d48b01e28ac5d07d145e",
		  #       "name": "Photo-Me International plc",
		  #       "address": "Photo-Me, Church Rd, KT23 3EU",
		  #       "phone": "01372 453399",
		  #       "enabled_inspections": false,
		  #       "enabled_hours_payroll": false
		  #     }
		  ]
	end
end
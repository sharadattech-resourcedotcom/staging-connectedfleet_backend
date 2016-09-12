class VehiclesController < ApplicationController
	def list
		if @session_user.role.access_level > 4
			vehicles = Vehicle.where(:company_id => @session_user.company_id).eager_load(:model, :manufacturer)
		else
			vehicles = Vehicle.where(:id => UserVehicle.user_vehicles_ids(@session_user.id))
		end
		vehicles = vehicles.where("registration ilike '%"+params[:search][:registration]+"%'") if params[:search][:registration] != nil
		vehicles = vehicles.where("vehicles.manufacturer_id = ?", params[:search][:manufacturer_id] ) if params[:search][:manufacturer_id] != nil
		vehicles = vehicles.where("model_id = ?", params[:search][:model_id] ) if params[:search][:model_id] != nil
		vehicles = vehicles.where("color ilike '%"+params[:search][:color]+"%'") if params[:search][:color] != nil
		vehicles = vehicles.where("fuel_type = ?", params[:search][:fuel_type]) if params[:search][:fuel_type] != nil
		vehicles = vehicles.where("transmission = ?", params[:search][:transmission] ) if params[:search][:transmission] != nil

		return render :json => {:status => true, :errors => [], :data => {:vehicles => vehicles.limit(100).offset((params[:page].to_i - 1)* 100), :count => vehicles.count}}
	end

	def details 
		vehicle = Vehicle.where(:id => params[:id]).take
		return render :json => {:status => true, :errors => [], :data => {:vehicle => vehicle}}
	end

	def vehicle_trips
		begin
			vehicle = Vehicle.find_by(:id => params[:vehicle_id])
			raise ["Vehicle not found."] if vehicle.nil?
			raise ["Access denied."] if vehicle.company_id != @session_user.company_id
			trips = vehicle.trips.joins(:user).select('trips.*', 'users.id AS driver_id', 'users.first_name', 'users.last_name', 'users.email').order(start_date: :desc)

			 if params[:page]
			 	count = nil
		        if params[:page] == 0
		            count = trips.length
		            params[:page] = 1
		        end
		        return render :json => {:status => true, :errors => [], :data => {:trips => trips.limit(50).offset((params[:page].to_i - 1)* 50), :count => count}}
		    else
		        return render :json => {:status => true, :errors => [], :data => {:trips => trips}}
		    end
		rescue => ex
			return render :json => {:status => false, :errors => ex, :data => nil}
		end
	end

	def update_details
		vehicle = Vehicle.where(:id => params[:vehicle][:id]).take
		vehicles = Vehicle.all
		if !vehicle.registration.nil?
			vehicles.each do |v|
				if params[:vehicle][:registration] == v.registration && vehicle.id != v.id
					return render :json => {:status => false, :errors => ["Vehicle with such registration already exist in database!"]}
				end
			end
		end

		if vehicle.manufacturer.description != 'Unknown' && params[:vehicle][:manufacturer_id] != vehicle.manufacturer_id
			return render :json => {:status => false, :errors => ["You are not able to change vehicle manufacturer!"]}
		end
		if vehicle.model.description != 'Unknown' && params[:vehicle][:model_id] != vehicle.model_id
			return render :json => {:status => false, :errors => ["You are not able to change vehicle model!"]}
		end

		if vehicle.valid?
			vehicle.update_attributes(vehicle_params)
			return render :json => {:status => true, :errors => [], :data => {}}
		end
		return render :json => {:status => false, :errors => vehicle.errors.full_messages, :data => {}}
	end

	def pre_data
		fuel_types  = ['Gasoline', 'Diesel', 'Hybrid', 'Electric']   
		transmissions = ['Automatic', 'Manual']
		manufacturers, models = @session_user.company.manufacturers

		return render :json => {:status => true, :errors => [], :data => {:fuel_types => fuel_types, :transmissions => transmissions, :manufacturers => manufacturers, :model => models}}
	end

	def create_vehicle
		ActiveRecord::Base.transaction do
			params[:vehicle][:company_id] = @session_user.company_id
			
			vehicle = Vehicle.new(vehicle_params)

			if !params[:vehicle][:manufacturer_text].nil? && params[:vehicle][:manufacturer_text] != ''
				man = Manufacturer.create(:description => params[:vehicle][:manufacturer_text], :company_id => @session_user.company_id)
				vehicle.manufacturer_id = man.id
			end

			if !params[:vehicle][:model_text].nil? && params[:vehicle][:model_text] != ''
				mod = Model.create(:description => params[:vehicle][:model_text], :manufacturer_id => vehicle.manufacturer_id)
				vehicle.model_id = mod.id
			end

			vehicles = Vehicle.all

			if !vehicle.registration.nil?
				vehicles.each do |v|
					if vehicle.registration == v.registration
						return render :json => {:status => false, :errors => ["Vehicle with such registration already exist in database!"]}
					end
				end
			end

			if vehicle.valid? 
				vehicle.save!
				render :json => {:status => true, :errors => []}
			else
				render :json => {:status => false, :errors => vehicle.errors.full_messages}
			end
		end
	end

	def vehicle_params
	  	params.require(:vehicle).permit(:company_id, :manufacturer_id, :model_id, :registration, :color, :engine, :transmission, :model_year, :fuel_type)
	end
end
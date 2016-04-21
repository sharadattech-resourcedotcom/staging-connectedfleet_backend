class InspectionsController < ApplicationController
	def list
		inspections = []
		if !params[:user_id].nil?
			if @session_user.role.access_level >= 8 || ManagerDriver.driver_manager(@session_user.company_id, params[:user_id]) || @session_user.id = params[:user_id]
				if @session_user.id == params[:user_id] && @session_user.access_level == 1
					inspections = MobileInspection.where(:vehicle_id => UserVehicle.user_vehicles_ids(@session_user.id))
				else
					inspections = MobileInspection.where(:user_id => params[:user_id])
				end
			end
		elsif !params[:vehicle_id].nil?
			if @session_user.role.access_level >= 8 || UserVehicle.has_access(@session_user.id, params[:vehicle_id])
				inspections = MobileInspection.where(:vehicle_id => params[:vehicle_id])
			end
		else
			if @session_user.role.access_level >= 8
				inspections = MobileInspection.joins(:user).where('users.company_id = ?', @session_user.company_id)
			elsif @session_user.role.access_level >= 4
				inspections = MobileInspection.where(:user_id => ManagerDriver.manager_drivers_ids(@session_user.company, @session_user))
			elsif @session_user.role.access_level >= 1
				inspections = MobileInspection.where(:vehicle_id => UserVehicle.user_vehicles_ids(@session_user.id))
			else
				inspections = MobileInspection.where(:user_id => @session_user.id)
			end
		end
		inspections = inspections.order('created_at DESC') unless inspections.empty?
		return render :json => {:status => true, :data => {:inspections => inspections}}
	end

	def details
		inspection = MobileInspection.where(:id => params[:id]).take
		driver = User.where(:id => inspection.user_id).take
		return render :json => {:status => true, :errors => [], :data => {:inspection => inspection, :driver => driver}}
	end

	def download_inspection_pdf
		inspection = MobileInspection.where(:id => params[:inspection_id]).take
		send_data InspectionsPdf.generate_pdf(inspection, params).render, type: "application/pdf", disposition: "inline"
	end
end
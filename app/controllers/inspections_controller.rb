class InspectionsController < ApplicationController
	def list
		inspections = []
		if !params[:user_id].nil?
			if @session_user.role.access_level >= 8 || ManagerDriver.driver_manager(@session_user.company_id, params[:user_id]) || @session_user.id = params[:user_id]
				if @session_user.id == params[:user_id] && @session_user.access_level == 1
					inspections = MobileInspection.where(:vehicle_id => UserVehicle.user_vehicles_ids(@session_user.id))
					inspections += EstimatorInspection.where(:vehicle_id => UserVehicle.user_vehicles_ids(@session_user.id))
				else
					inspections = MobileInspection.where(:user_id => params[:user_id])
					inspections += EstimatorInspection.where(:driver_id => params[:user_id])
				end
			end
		elsif !params[:vehicle_id].nil?
			if @session_user.role.access_level >= 8 || UserVehicle.has_access(@session_user.id, params[:vehicle_id])
				inspections = MobileInspection.where(:vehicle_id => params[:vehicle_id])
				inspections += EstimatorInspection.where(:vehicle_id => params[:vehicle_id])
			end
		else
			if @session_user.role.access_level >= 8
				inspections = MobileInspection.joins(:user).where('users.company_id = ?', @session_user.company_id)
				inspections += EstimatorInspection.joins(:driver).where('users.company_id = ?', @session_user.company_id)
			elsif @session_user.role.access_level >= 4
				inspections = MobileInspection.where(:user_id => ManagerDriver.manager_drivers_ids(@session_user.company, @session_user))
				inspections += EstimatorInspection.where(:driver_id => ManagerDriver.manager_drivers_ids(@session_user.company, @session_user))
			elsif @session_user.role.access_level >= 1
				inspections = MobileInspection.where(:vehicle_id => UserVehicle.user_vehicles_ids(@session_user.id))
				inspections += EstimatorInspection.where(:vehicle_id => UserVehicle.user_vehicles_ids(@session_user.id))
			else
				inspections = MobileInspection.where(:user_id => @session_user.id)
				inspections += EstimatorInspection.where(:user_id => @session_user.id)
			end
		end
		inspections = inspections.as_json.sort_by {|h| h['created_at']}.reverse unless inspections.empty?
		return render :json => {:status => true, :data => {:inspections => inspections}}
	end

	def details
		if params[:inspection_type] && params[:inspection_type] == 'E'
			inspection = EstimatorInspection.find_by(:id => params[:id])
			driver = User.where(:id => inspection.driver_id).take
		else
			inspection = MobileInspection.where(:id => params[:id]).take
			driver = User.where(:id => inspection.user_id).take
		end
		
		return render :json => {:status => true, :errors => [], :data => {:inspection => inspection, :driver => driver}}
	end

	def download_inspection_pdf
		inspection = MobileInspection.where(:id => params[:inspection_id]).take
		send_data InspectionsPdf.generate_pdf(inspection, params).render, type: "application/pdf", disposition: "inline"
	end

	def download_gemini_inspection_pdf
		@inspection = MobileInspection.find(params[:inspection_id])
        @vehicle = @inspection.vehicle
        @driver = @inspection.user
        @job = @inspection.job.nil? ? nil : @inspection.job
        @appointment = @job.nil? || @job.appointment.nil? ? nil : @job.appointment
        @damage_collections = @inspection.damage_collections
        @damages = @damage_collections.nil? ? nil : @inspection.damageItems
        @interior = @damage_collections.where("collection_type = 'INTERIOR'")
        @exterior = @damage_collections.where("collection_type = 'EXTERIOR'")
        @ex_dots = []

        respond_to do |format|
            format.pdf do
                render  :pdf => "inspection_#{params[:inspection_id]}_#{Date.today}", :template => 'pdf_templates/gemini.pdf.erb', :page_size => "A4"
            end
        end
	end

	def download_clm_inspection_pdf
		@inspection = MobileInspection.find(params[:inspection_id])
        @vehicle = @inspection.vehicle
        @driver = @inspection.user
        @job = @inspection.job.nil? ? nil : @inspection.job
        @appointment = @job.nil? || @job.appointment.nil? ? nil : @job.appointment
        @damages = @inspection.damageItems

        respond_to do |format|
            format.pdf do
                render  :pdf => "inspection_#{params[:inspection_id]}_#{Date.today}", :template => 'pdf_templates/clm.pdf.erb', :page_size => "A4"
            end
        end
	end

	def download_estimator_inspection_pdf
		@inspection = EstimatorInspection.find(params[:inspection_id])
        @vehicle = @inspection.vehicle
        @driver = @inspection.driver      
        @collections = @inspection.damage_collections
        @img_path = @inspection.vehicle_type == 'VAN' ? "#{Rails.root}/public/van_exterior.png" : "#{Rails.root}/public/car_exterior.png"
        @img_size = FastImage.size(@img_path)
        @scale = 0.8
        @date = @inspection.event_timestamp.in_time_zone("London").to_s
        @date = @date[0...@date.length - 9]
        respond_to do |format|
            format.pdf do
                render  :pdf => "estimator_inspection_#{params[:inspection_id]}_#{@inspection.event_timestamp}", :template => 'pdf_templates/estimator.pdf.erb', :page_size => "A4"
            end
        end
	end
end
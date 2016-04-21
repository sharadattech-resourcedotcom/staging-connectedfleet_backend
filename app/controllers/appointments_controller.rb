class AppointmentsController < ApplicationController
	def list
		if @session_user.role.access_level > 4
			appointments = Appointment.where(:company_id => @session_user.company_id).eager_load(:branch, :product, :insurance_company).order(id: :desc)
		elsif @session_user.role.access_level < 4
			appointments = Appointment.by_vehicles_access(@session_user.id).eager_load(:branch, :product, :insurance_company).order(id: :desc).eager_load(:branch, :product, :insurance_company).order(id: :desc)
		else
			appointments = Appointment.by_drivers_access(@session_user).eager_load(:branch, :product, :insurance_company).order(id: :desc)
		end

		if !params[:search].nil?
			appointments = appointments.where(:branch_id => params[:search][:branch_id]) if params[:search][:branch_id] != nil
			appointments = appointments.where(:product_id => params[:search][:product_id]) if params[:search][:product] != nil
			appointments = appointments.where(:insurance_company_id => params[:search][:insurance_company_id]) if params[:search][:insurance_company_id] != nil
			appointments = appointments.where(:vehicle_id => params[:search][:vehicle_id]) if params[:search][:vehicle_id] != nil
			return render :json => {:status => true, :errors => [], :data => {:appointments => appointments.limit(100).offset((params[:page].to_i - 1)* 100), :count => appointments.count}}
		else
			appointments = appointments.where(:vehicle_id => params[:vehicle_id].to_i) if params[:vehicle_id] != nil
			appointments = appointments.joins(:job).where(:user_id => params[:user_id]) if params[:user_id] != nil
			return render :json => {:status => true, :errors => [], :data => {:appointments => appointments}}
		end		
	end

	def pre_data
		branches  = Branch.where(:company_id => @session_user.company_id)   
		products = Product.where(:company_id => @session_user.company_id) 
		vehicles = Vehicle.where(:company_id => @session_user.company_id) 
		insurance_companies = InsuranceCompany.where(:company_id => @session_user.company_id) 
		return render :json => {:status => true, :errors => [], :data => {:branches => branches, :products => products, :insurance_companies => insurance_companies, :vehicles => vehicles}}
	end

	def details
		appointment = Appointment.where(:id => params[:id]).take
		inspections = appointment.job.mobileInspections
		return render :json => {:status => true, :errors => [], :data => {:appointment => appointment, :driver => appointment.job.user, :inspections => inspections}}
	end

	def create_appointment
		params[:appointment][:company_id] = @session_user.company_id
		appointment = Appointment.new(appointment_params)
		ActiveRecord::Base.transaction do
			if appointment.valid?
				appointment.build_job(:status => 0)

				#FOR GEMINI
				if @session_user.company_id == 8
					appointment.build_collection_job(:status => 0, :job_type => 'C')
				end
				###########
				appointment.save!
				job_number = appointment.job.id.to_s
				abort_code =  (0...4).map { (65 + rand(26)).chr }.join
				while job_number.length < 8
					job_number = job_number.insert(0,'0')
				end
				appointment.job.update_attributes(number: job_number, abort_code: abort_code)

				#FOR GEMINI
				if @session_user.company_id == 8
					col_job_number = appointment.collection_job.id.to_s
					while col_job_number.length < 8
						col_job_number = col_job_number.insert(0,'0')
					end
					appointment.collection_job.update_attributes(number: col_job_number, abort_code: abort_code)
				end
				##########
				return render :json => {:status => true, :errors => []}
			else
				return render :json => {:status => false, :errors => appointment.errors.full_messages}
			end
		end
		        
	end

	def update_details
		appointment = Appointment.where(:id => params[:appointment][:id]).take
		if appointment.valid?
			appointment.update_attributes(appointment_params)
			return render :json => {:status => true, :errors => [], :data => {}}
		end
		return render :json => {:status => false, :errors => appointment.errors.full_messages, :data => {}}
	end

	def appointment_params
	  	params.require(:appointment).permit(:company_id, :branch_id, :product_id, :insurance_company_id, :vehicle_id, :claim_number,
	  				:excess, :contact_name, :email, :street, :col_street, :col_postcode, :col_city, :city, :postcode, :mobile, :home_phone, :work_phone, :notes,
	  				:insurer, :vatstatus, :customername, :customerphone, :courtesy_car)
	end
end
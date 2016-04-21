class HoursPayrollController < ApplicationController

	def fetch_drivers_types
		types = DriverType.where(:company_id => @session_user.company_id)
		return render :json => {:data => {:types => types, :branches => @session_user.company.branches}}
	end

	def save_driver_type
		type = DriverType.where("company_id = ? AND name = ?", @session_user.company_id, params[:type][:name]).take
		if !type.nil?
			type.update_attributes(hourly_rate: params[:type][:hourly_rate], additional_hour_rate: params[:type][:additional_hour_rate])
		else
			type = DriverType.new
			type.company_id = @session_user.company_id
			type.name = params[:type][:name]
			type.hourly_rate = params[:type][:hourly_rate]
			type.additional_hour_rate = params[:type][:additional_hour_rate]
			type.save!
		end
		return render :json => {:status => true}
	end
	
end
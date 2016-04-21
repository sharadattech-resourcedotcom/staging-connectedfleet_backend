class SchedulerController < ApplicationController
	
	def save_new_jobs
		jobs = params[:jobs]
		return_jobs = []
		jobs.each do |job|
			start_time = job[:start_date].to_time
			start_time = DateTime.parse(params[:date]).change({ hour: start_time.hour, min: start_time.min, sec: start_time.sec }).utc
			end_time = job[:end_date].to_time
			end_time = DateTime.parse(params[:date]).change({ hour: end_time.hour, min: end_time.min, sec: end_time.sec }).utc
			if job[:start_date].nil? || job[:end_date].nil? || job[:user_id].nil? || job[:appointment_id].nil? || start_time > end_time
				return_jobs.push(job)
			else
				if job[:job_type].nil?
					j = Job.where(:appointment_id => job[:appointment_id]).take
				else
					j = Job.where("appointment_id = ? AND job_type = ?", job[:appointment_id], job[:job_type]).take
				end
				if j.nil?
					return render :json => {:status => false, :errors => ["Job for appointment wasn't found"],
									:data => {:jobs => params[:jobs]}}
				end
				j.user_id = job[:user_id]
				j.start_date = start_time
				j.end_date = end_time
				j.is_acknowledged = false
				j.status = 1
				j.save!
			end
		end
		if return_jobs.count > 0
			if return_jobs.count == jobs.count 
				return render :json => {:status => false, :errors => ["Please fill in all fields, check whether end time is later than start time and try again."],
									:data => {:jobs => return_jobs}}
			else
				return render :json => {:status => false, :errors => ["Not all jobs have been saved. Please fill in all fields in the other jobs, check whether end time is later than start time and try again."],
									:data => {:jobs => return_jobs}}
			end
		else
			return render :json => {:status => true, :errors => [], :data => {}}
		end
	end

	def fetch_data_to_allocate
		appointments = @session_user.company.appointments.eager_load(:job).where("status = 0")
	    #drivers = User.all_with_role('Driver').order('last_name desc')
	    
	    return render :json => {:status => true, :errors => [], :data => {:appointments => appointments}}
	end

	def fetch_data_for_date
		jobs = @session_user.company.jobs.where("DATE(start_date) >= ? AND DATE(end_date) <= ?", Date.parse(params[:date]), DateTime.parse(params[:date]) + 1.day)
		drivers = @session_user.company.users.all_with_role('Driver')

		return render :json => {:status => true, :errors => [], :data => {:jobs => jobs, :drivers => drivers}}
	end

	def fetch_driver_jobs
		jobs = @session_user.company.jobs.where("(DATE(start_date) >= ? AND DATE(end_date) <= ?) AND user_id = ?", Date.parse(params[:date]), DateTime.parse(params[:date]) + 1.day, params[:user_id])
		
		return render :json => {:status => true, :errors => [], :data => {:jobs => jobs}}
	end

	def delete_job
		job = @session_user.company.jobs.where(:id => params[:job][:id]).take
		job.user_id = nil
		job.start_date = nil
		job.end_date = nil
		job.status = 0
		job.save!

		return render :json => {:status => true, :errors => [], :data => {}}
	end
end
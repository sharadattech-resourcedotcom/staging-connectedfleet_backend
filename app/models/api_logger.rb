class ApiLogger < ActiveRecord::Base
	belongs_to :user

	def user_info 
		u = self.user
		user = {:fullname => u.full_name, :email => u.email}
		return user	
	end

	def as_json(options={})
      super(:only => [:id, :app_version, :user_id, :log_type, :input_val, :output_val, :created_at, 
                       :updated_at, :succeeded], :methods => [:user_info])
  	end 

  	def self.checked(input)
  		 logs = ApiLogger.where(:input_val => input)
  		 logs.each do |l|
  		 	l.update_attribute(:web_checked, true)
  		 end
  	end

	def self.cron_job
		logs = ApiLogger.where("DATE(created_at) = ? AND cron_checked = false", Date.today)
		failed_logs = []
		logs.each do |log|
			log.update_attribute(:cron_checked, true)
			if log.succeeded = 0
				failed_logs.push(log)
			end
		end

		if failed_logs.size > 0
			MailSender.send_email_about_log_synchronize_failed(failed_logs)
		end
	end
end

class CompanyEmail < ActiveRecord::Base
	belongs_to :company
	validates_presence_of :company_id, :recipients, :subject, :content

	def self.variables
		vars = Hash.new
		vars['Inspection job completed'] = ["[DRIVER_NAME] "," [VEHICLE_REGISTRATION] "," [VEHICLE_MANUFACTURER] "," [VEHICLE_MODEL] "," [LOOSE_ITEMS] "," [NOTES] "," [QUESTIONS]", " [CONTACT_EMAIL]", " [CONTACT_NAME]"]
		vars['Closed period'] = ["[AGENT_EMAIL]","[AGENT_NAME]","[DRIVER_NAME]","[APPROVE_LINK]","[PERIOD_START_DATE]","[PERIOD_END_DATE]","[PERIOD_PRIVATE_MILEAGE]","[PERIOD_BUSINESS_MILEAGE]","[PERIOD_ID]"]
		vars['Unclosed period'] = ["[AGENT_EMAIL]","[DRIVER_NAME]","[PERIOD_START_DATE]","[PERIOD_ID]"] 
		vars['Reminder to agents'] = ["[AGENT_EMAIL]","[AGENT_NAME]","[DRIVER_NAME]","[APPROVE_LINK]","[PERIOD_START_DATE]","[PERIOD_END_DATE]","[PERIOD_PRIVATE_MILEAGE]","[PERIOD_BUSINESS_MILEAGE]","[PERIOD_ID]"]
		return vars
	end

	def self.types
		  return ['Closed period', 'Reminder to agents'	,'Inspection job completed']
	end

	def body(object)
		new_body = self.content
		object.email_variables.each do |k, v|
			new_body = new_body.gsub("[" + k.to_s + "]", v.to_s)
		end
		return new_body
	end

	def desc_subject(object)
		new_subject = self.subject
		object.email_variables.each do |k, v|
			new_subject = new_subject.gsub("[" + k.to_s + "]", v.to_s)
		end
		return new_subject
	end

	def self.default_emails(company_id)
		email = CompanyEmail.where("company_id = ? AND email_type = 'Closed period'", company_id).take
		email = CompanyEmail.new(:company_id => company_id, :email_type => 'Closed period') if email.nil?
		email[:subject] = '[DRIVER_NAME] month end completed'
		email[:recipients] = '[AGENT_EMAIL]'
		email[:content] =  "Hi [AGENT_NAME]\n"+
					"The month end for [DRIVER_NAME] has now been closed. Please login to [APPROVE_LINK] to review their mileage log for past month and authorise their final mileage."+
					" If there are any discrepancies, please amend  as necessary before submitting, as your authorisation will be passed to payroll for [DRIVER_NAME] salary deduction."+
					"\n\nIf you have any issues amending or authorising the log, please contact CLM on 01908219361."
		email.save!

		email = CompanyEmail.where("company_id = ? AND email_type = 'Reminder to agents'", company_id).take
		email = CompanyEmail.new(:company_id => company_id, :email_type => 'Reminder to agents') if email.nil?
		email[:subject] = 'Outstanding driver mileage submissions requiring authorisation'
		email[:recipients] = '[AGENT_EMAIL]'
		email[:content] =  "Dear [AGENT_NAME]\n"+
						"The following driver’s month end mileages have not yet been authorised: [DRIVER_NAME]\n"+
						"Please login to [APPROVE_LINK] to review their mileage log for past month and authorise their final mileage.\n"+
					" It is important that these are reviewed and authorised by close of business on the 9th – after which time they will be automatically authorised, passed to payroll and the driver’s salary will be deducted with the relevant amounts.\n"+
					"\nIf you have any issues amending or authorising the log, please contact CLM on 01908219361."
		email.save!

		email = CompanyEmail.where("company_id = ? AND email_type = 'Inspection job completed'", company_id).take
		email = CompanyEmail.new(:company_id => company_id, :email_type => 'Inspection job completed') if email.nil?
		email[:subject] = 'Inspection job completed.'
		email[:recipients] = '[CONTACT_EMAIL]'
		email[:content] =  "	Dear [CONTACT_NAME]\n"+
						"Inspection job for vehicle [VEHICLE_MANUFACTURER] [VEHICLE_MODEL] ([VEHICLE_REGISTRATION]) has been completed.\n"+
						"See atachment to review inspection details.\n"
		email.save!


	end
end

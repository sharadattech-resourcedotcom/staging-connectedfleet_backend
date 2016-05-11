class DefaultEmailTemplates < ActiveRecord::Migration
  def change
  	Company.all.each do |company|
  		CompanyEmail.default_emails(company.id)
  	end
  end
end

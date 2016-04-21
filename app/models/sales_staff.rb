class SalesStaff < ActiveRecord::Base
	belongs_to :user
	belongs_to :company
	validates_presence_of :user_id, :company_id

	def self.email_content(company_id)
		staff = SalesStaff.where("company_id = ?", company_id)
		content = "<h2>Sales Staff report for date: "+Date.today.strftime("%F")+"<h2><br>"
		content = content + "<table border='1'><tr><th>User</th><th>Last request</th></tr>"
		staff.each do |s|
			user = User.find(s.user_id)
			content = content + "<tr>"
			if user.last_request.nil? || user.last_request < Time.current.change(hour: 0, min: 0)
				content = content + "<td ><font color='red'>" + user.full_name + "   </font></td>" 
				content = content + "<td>" + user.last_request + "</td>" if !user.last_request.nil?
				content = content + "<td>UNKNOWN</td>" if user.last_request.nil?
			else
				content = content + "<td>" + user.full_name + "   </td><td>" + user.last_request.strftime("%F %T") + "</td>"
			end
			content = content + "</tr>"
		end
		content = content + "</table>"
		return content
	end
end
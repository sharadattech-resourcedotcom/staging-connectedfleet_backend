require 'csv'
require 'net/ftp'

class FtpService
	def self.generate_and_send_photome_monthly_csv(date)
		date = Date.parse(date) if !date.kind_of?(Date)
		columns, values = Reports::PayrollReport.generate(User.where(:company_id => 4).take, date.to_s, nil, nil)
		file_name = ("Photome_" + date.strftime("%B") + "_" + date.year.to_s + ".csv").downcase
		file = File.join(Rails.root, "csv/" + file_name)

		CSV.open(file, "w") do |csv|
			csv << ['Driver', 'Vehicle', "Total Business Mileage", 'Total Private Mileage']
			values.each do |row|
				csv << [
					row[1],
					row[2],
					row[8],
					row[9]
				]
			end
		end
		self.send_file_to_nexus(file)
	end

	def self.send_file_to_nexus(file_path)
		begin
			unless file.nil?
				Net::SFTP.start('213.129.76.25', 'nexusftp', :password => 'T;nov5?(') do |sftp|
					sftp.upload!(file_path, "CF/" + File.basename(file_path))
					MailSender.send_upload_confirm(true, file_path, "Photome - Nexus")
				end
			end
		rescue => ex
			MailSender.send_upload_confirm(false, file_path, "Photome - Nexus", ex.backtrace)
		end
	end
end

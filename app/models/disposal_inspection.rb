require 'net/ftp'

class DisposalInspection < ActiveRecord::Base
	belongs_to :user
	has_many :disposal_photos
	validates_presence_of :registration

	def send_to_epyx
		file_path = nil
		begin
			Net::FTP.open("ftp1.1link.co.uk", "clm", "P3tr0lT@nk3r") do |ftp|
				self.disposal_photos.each{|photo|
					file_path = File.join(Rails.root, photo.path)
					ftp.chdir("/DN-Upload/marketing")
	                ftp.putbinaryfile(file_path, photo.ftp_filename)
	                photo.sent = true
	                photo.save!
				}
			end
			self.update_attribute(:all_sent, true)
		rescue => ex
			puts ex.backtrace
			puts "***********"
			puts ex.message
			# MailSender.send_upload_confirm(false, file_path, "1Link", ex.backtrace)
		end
	end	

	def self.one_link_cron
		DisposalInspection.where("all_sent = FALSE").each do |insp|
			insp.send_to_epyx
		end
	end
end
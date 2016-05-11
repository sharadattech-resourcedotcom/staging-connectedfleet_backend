# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

set :output, "log/cron.log"


# every 1.minute do
#    runner "EndMonthProcess.auto_close_drivers_trips"
# end


every 1.month, :at => 'Januar 1st 9:00 am' do
   runner 'EndMonthProcess.send_driver_first_reminder(4)'
end

every 1.month, :at => 'January 3rd 9:00 am' do
   runner 'EndMonthProcess.send_driver_second_reminder(4)'
end

# every 1.month, :at => 'January 5th 9.00 am' do
#    runner "EndMonthProcess.auto_close_drivers_trips"
# end

every 1.month, :at => 'January 9th 9.00 am' do
   runner "EndMonthProcess.send_reminder_to_agents", :environment => 'production'
end

# every 1.month, :at => 'January 10th 9.00 am' do

# end
# every 30.minutes do
# 	runner "ApiLogger.cron_job", :environment => 'development'
# end

every 15.minutes do 
	runner "Payroll.calculate_for(Date.today)", :environment => 'production'
	runner "Payroll.calculate_for(Date.today - 1.day)", :environment => 'production'
end

every 15.minutes do 
	runner "DisposalInspection.one_link_cron", :environment => 'production'
end

every 1.day, :at => '10:05 am' do 
	runner "MailSender.send_sales_staff_reports", :environment => 'production'
end

every 15.minutes do 
	runner "Company.cron_job", :environment => 'production'
end

every 15.minutes do 
	runner "TripStat.cron_job(1000, false)", :environment => 'production'
end
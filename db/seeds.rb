# periods = Period.where("start_date > ? and start_date < ? and status <> 'closed'", '2015-02-15', '2015-03-15')
# puts periods.count.to_s

# periods.each do |p|
# 	if p.user.company_id = 4
# 		puts p.user.company_id.to_s + " " +p.user.email + " " + p.status + " " + p.start_date.to_s
#         #       MailSender.send_email_about_unclosed_period(p)
#     end
# end

# periods = Period.where("start_date > ? and start_date < ? and status = 'closed' and approved = false", '2015-01-25', '2015-02-15')
# periods.each do |p|
# 	puts p.start_date.to_s + ', ' + p.end_date.to_s + ' => ' + p.agent_email
# 	MailSender.send_reminder_to_agent(p)
# end

# users_ids = []
# periods.each do |p|
# 	puts 'Double user id ' + p.user_id.to_s if users_ids.include? p.user_id
# 	users_ids.push(p.user_id)
# end

# for each period change its start date to 01.02.2015

# to verify trips start date
# select email, start_date, period_start_date from trips inner join users on users.id = trips.user_id where start_date >= '2015-02-01 00:00:00' order by period_start_date desc;

# ActiveRecord::Base.transaction do
# 	periods = Period.where("start_date < '2015-01-15' and end_date < '2015-02-15' and end_date > '2015-01-15'").order('start_date asc')

# 	periods.each do |p|
# 		if p.user.id == 178 then next end

# 		puts 'Jan period ' + p.start_date.to_s + ' ' + p.end_date.to_s + ' ' + p.user.id.to_s

# 		trips = Trip.where("to_char(period_start_date, 'YYYY-MM-DD')  = ? AND user_id = ?", p.start_date.strftime('%F'), p.user_id)
# 		trips.update_all(:period_start_date => nil)
		
# 		p.end_date = '2015-01-31 23:59:00'
# 		p.save

# 		raise 'Period not valid' unless p.valid?

# 		trips = Trip.where("period_start_date IS NULL AND user_id = ?", p.user_id)
# 		trips.update_all(:period_start_date => p.start_date)
# 	end

# 	periods = Period.where("start_date > '2015-01-15' AND end_date IS NULL").order('start_date asc')
	
# 	periods.each do |p|
# 		if p.user.id == 178 then next end

# 		puts 'Jan period ' + p.start_date.to_s + ' ' + p.end_date.to_s + ' ' + p.user.id.to_s

# 		trips = Trip.where("to_char(period_start_date, 'YYYY-MM-DD')  = ? AND user_id = ?", p.start_date.strftime('%F'), p.user_id)
# 		trips.update_all(:period_start_date => nil)
		
# 		p.start_date = '2015-02-01 00:00:00'
# 		p.save

# 		raise 'Period not valid' unless p.valid?

# 		trips = Trip.where("period_start_date IS NULL AND user_id = ?", p.user_id)
# 		trips.update_all(:period_start_date => p.start_date)
# 	end

# 	users = User.all

# 	users.each do |u|
# 		period_jan = Period.where("to_char(end_date, 'YYYY-MM') = ? AND user_id = ?", '2015-01', u.id).take
# 		period_feb = Period.where("to_char(start_date, 'YYYY-MM') = ? AND user_id = ?", '2015-02', u.id).take

# 		puts 'Jan periods not found ' + u.email if period_jan.nil?
# 		# puts 'Jan period ' + period_jan.start_date.to_s + ' ' + period_jan.end_date.to_s + ' ' + u.email unless period_jan.nil?
# 		puts 'Feb periods not found ' + u.email if period_feb.nil?

# 		unless period_jan.nil?
# 			Trip.where("to_char(end_date, 'YYYY-MM') = ? AND user_id = ?", '2015-01', u.id).update_all(:period_start_date => period_jan.start_date)
# 		end

# 		unless period_feb.nil?
# 			Trip.where("to_char(end_date, 'YYYY-MM') = ? AND user_id = ?", '2015-02', u.id).update_all(:period_start_date => period_feb.start_date)
# 		end
# 	end
# end


# Spreadsheet.client_encoding = 'UTF-8'

# book = Spreadsheet.open "#{Rails.root}/db/payroll_numbers.xls"

# sheet1 = book.worksheet 'Fleet List'

# it = 0

# ActiveRecord::Base.transaction do
# 	sheet1.each do |row|
# 		u = User.where("lower(first_name) ilike '%"+row[0].downcase+"%' AND lower(last_name) ilike '%"+row[1].downcase+"%'")
# 		puts 'User not found' + row.to_json if u.length == 0
# 		puts 'To many matches for' + u.to_json if u.length > 1
# 		u.update_all(:payroll_number => row[2])
# 	end
# end

# for each user 


# puts periods.to_json


# raise periods.to_json

# unless ENV['managers_drivers'].nil?
#   require File.expand_path('db/seeds/managers_drivers.rb')
# end

# trips = Trip.where("start_date > '2014-11-27' AND start_date < '2014-12-01'").order('id desc')
#
# puts 'Found: '+ (trips.length).to_s
#
# ids = []
# trips.each do |t|
#   # puts t.id
#   ids.push(t.id)
# end
#
# puts ids.join(',')

#
company = Company.new
company.name = '3Reign'
company.address = 'London'
company.phone = '01509881001'
company.login = 'reign'
company.password = 'reign'
company = Company.create(company)

user = User.new
user.first_name = 'Steve'
user.last_name = 'Edwards'
user.user_type = '8'
user.phone = '07712489411'
user.email = 'steveCEO@3reign.com'
user.password = 'steve123'
user.on_trip = false
user = User.create(user, company.id)

user = User.new
user.first_name = 'Steve'
user.last_name = 'Edwards'
user.user_type = '2'
user.phone = '07712489411'
user.email = 'steveManager@3reign.com'
user.password = 'steve123'
user.on_trip = false
user = User.create(user, company.id)

user = User.new
user.first_name = 'Steve'
user.last_name = 'Edwards'
user.user_type = '1'
user.phone = '07712489411'
user.email = 'steveDriver@3reign.com'
user.password = 'steve123'
user.on_trip = false
user = User.create(user, company.id)

company = Company.new
company.name = 'AppsVisio'
company.address = 'Gdansk Grunwaldzka 76/78'
company.phone = '+48 668 429 587'
company.login = 'appsvisio'
company.password = 'appsvisio123'
company = Company.create(company)

user = User.new
user.first_name = 'Apps'
user.last_name = 'Visio'
user.user_type = '4'
user.phone = '07712489411'
user.email = 'appsvisioCEO@appsvisio.com'
user.password = 'appsvisio123'
user.on_trip = false
user = User.create(user, company.id)

user = User.new
user.first_name = 'Apps'
user.last_name = 'Visio'
user.user_type = '2'
user.phone = '07712489411'
user.email = 'appsvisioManager@appsvisio.com'
user.password = 'appsvisio123'
user.on_trip = false
user = User.create(user, company.id)

user = User.new
user.first_name = 'Radek'
user.last_name = 'Wasiuk'
user.user_type = '1'
user.phone = 'radek-radek'
user.email = 'radek@appsvisio.com'
user.password = 'radek123'
user.on_trip = false
user = User.create(user, company.id)

user = User.new
user.first_name = 'Michal'
user.last_name = 'Rogowski'
user.user_type = '1'
user.phone = 'michal-michal'
user.email = 'michalrogowski@appsvisio.com'
user.password = 'michal123'
user.on_trip = false
user = User.create(user, company.id)


user = User.new
user.first_name = 'Jakub'
user.last_name = 'Kozlowski'
user.user_type = '1'
user.phone = 'kuba-kuba'
user.email = 'kuba@appsvisio.com'
user.password = 'kuba123'
user.on_trip = false
user = User.create(user, company.id)


user = User.new
user.first_name = 'Michal'
user.last_name = 'Rychlik'
user.user_type = '1'
user.phone = 'michal-michal'
user.email = 'michalrychlik@appsvisio.com'
user.password = 'michal123'
user.on_trip = false
user = User.create(user, company.id)


company = Company.new
company.name = 'CLM'
company.address = 'London'
company.phone = '252525'
company.login = 'clm'
company.password = 'clm'
company = Company.create(company)

user = User.new
user.first_name = 'Paul'
user.last_name = 'Hurst'
user.user_type = '4'
user.phone = '2222'
user.email = 'paul.hurst.copy@clm.co.uk'
user.password = 'paul123'
user.on_trip = false
user.is_line_manager = true
user = User.create(user,company.id )

company = Company.new
company.name = 'Photo-Me International plc'
company.address = 'Photo-Me, Church Rd, KT23 3EU'
company.phone = '01372 453399'
company.login = 'photome'
company.password = 'photome'
company = Company.create(company)

photome_id = company.id

user = User.new
user.first_name = 'Richard'
user.last_name = 'Dicey'
user.user_type = '4'
user.phone = '07788 720915'
user.email = 'richard.dicey@photo-me.com'
user.password = 'diceyrich15'
user.is_line_manager = true
user.on_trip = false
user = User.create(user, company.id)

user = User.new
user.first_name = 'PhotoMe Admin'
user.last_name = 'PhotoMe Admin'
user.user_type = '4'
user.phone = ' '
user.email = 'phoadmin@clm.co.uk'
user.password = 'phclm71'
user.is_line_manager = true
user.on_trip = false
user = User.create(user, company.id)

user = User.new
user.first_name = 'Niall'
user.last_name = 'Frazer'
user.user_type = '4'
user.phone = '07989 562640'
user.email = 'niall.frazer@photo-me.com'
user.password = 'frazerniall40'
user.on_trip = false
user = User.create(user, company.id)
#
# if ENV['dump_trips'] == 'yes'
#
#   trips = Trip.all.order('user_id ASC, id ASC')
#
#   # raise trips.to_json
#   Spreadsheet.client_encoding = 'UTF-8'
#
#   book = Spreadsheet::Workbook.new
#   sheet1 = book.create_worksheet :name => 'Trips'
#
#   # set default column formats
#
#   sheet1.row(0).push "First name", "Last name", "Email", "Start location", "End location", "Start date", "End date", "Start mileage", "End mileage", "Additional informations in CSV"
#
#   iterator = 1
#
#   trips.each do |t|
#     sheet1.row(iterator).push t.user.first_name, t.user.last_name, t.user.email, t.start_location, t.end_location, t.start_date, t.end_date, t.start_mileage, t.end_mileage
#     iterator += 1
#   end
#
#   book.write 'trips_' + Date.today.to_s + '.xls'
# end
#
#
# #PHOTOME drivers adding from xls file
# Spreadsheet.client_encoding = 'UTF-8'
#
# book = Spreadsheet.open "#{Rails.root}/db/Mileage_03122014.xls"
#
# sheet1 = book.worksheet 'Sheet1'
#
# photome_id = 4
#
# it = 0
#
# # ActiveRecord::Base.transaction do
# sheet1.each 1 do |row|
#
#   it = it + 1
#
#   puts it.to_s
#
#   driver_email = row[2].to_s
#
#   #puts 'adding '+ driver_email.to_s
#
#   # driver = User.find_by(email: driver_email, user_type: 1)
#   driver = User.where('LOWER(email) = ? AND user_type = ?', driver_email.downcase, 1).take
#
#    if driver.nil?
#       #There is no user with that email create user
#       # raise 'Driver not found'
#
#       user = User.create({:first_name => row[0].to_s, :last_name => row[1].to_s, :user_type => 1, :phone => '', :email => row[2].to_s,
#         :on_trip => false, :password => (row[0][0..2].to_s + row[1][0..2].to_s + "123").downcase}, photome_id)
#
#       user.save
#
#       driver = user
#
#       puts 'CREATE DRIVER '+ driver.email
#
#    end
#
#
#    #Check if user has period
#    if (driver.periods.nil? || driver.periods.empty?)
#
#       puts '-----------------'
#       puts 'CREATE PERIOD FOR '+ driver.email
#       puts '-----------------'
#
#       p = Period.new
#           p.user_id=driver.id
#           p.start_date=row[5]
#           p.start_mileage=row[7]
#           p.status='opened'
#           p.approved = false
#           p.reminder_status = ''
#           p.agent_email = ''
#       raise p.errors.to_json unless p.valid?
#
#       p.save
#
#    end
#
#   if driver.periods.last.start_date < Date.parse('2014-10-01')
#     raise 'Period date '+ driver.periods.last.normalized_start_date + ' is lower'
#   end
#
#   #puts(driver.to_json)
#   line_managers = ['richard.dicey@photo-me.com', 'garry.richardson@photo-me.com', 'alfie.smith@photo-me.com', 'phil.dixon@photo-me.com', 'jim.mccartney@photo-me.com', 'kevin.nichols@photo-me.com',
#      'dave.stock@photo-me.com', 'gary.smith@photo-me.com', 'steven.murray@photo-me.com', 'stephen.lynch@photo-me.com', 'peter.mackay@photo-me.com', 'tom.simons@photo-me.com',
#      'tim.ayles@photo-me.com', 'sean.fairnell@photo-me.com', 'paul.hurs@clm.co.uk', 'steve.woodbridge@photo-me.com']
#
#   d = driver.trips.create(start_date: row[5],
#                        end_date: row[6],
#                        start_mileage: row[7],
#                        end_mileage: row[8],
#                        user_id:driver.id,
#                        estimated_time: 0,
#                        start_location: 'N/A',
#                        end_location: 'N/A',
#                        start_lat:0,
#                        vehicle_reg_number: row[10].to_s,
#                        end_lat:0,
#                        start_lon:0,
#                        end_lon:0,
#                        status:'N/A',
#                        period_start_date: driver.periods.last.start_date)
#
#   unless d.valid?
#     raise 'Trip is invalid'
#   end
#                        if line_managers.include?(driver.email.downcase)
#                          driver.is_line_manager = true
#                          driver.save
#                        end
#
#                        driver.vehicle_reg_number = row[10].to_s
#                        driver.save
#
#   unless driver.valid?
#     raise 'driver is invalid..'
#   end
# end
# # end
#
# periods = Period.all
# periods.each do |p|
#   #puts 'refreshing period '+ p.user_id.to_s
#   p.refresh_mileage
# end

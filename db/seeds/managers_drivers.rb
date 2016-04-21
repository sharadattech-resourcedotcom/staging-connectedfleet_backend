
# 1: Update all managers as NORMAL
User.where('is_line_manager = true').update_all(:manager_type => 'NORMAL')

# 2: Update these as ADMINS
['richard.dicey@photo-me.com', 'steven.murray@photo-me.com', 'peter.mackay@photo-me.com'].each do |e|
  u = User.where('email ilike ?', e).take
  raise 'Manager not found' + e if u.nil?

  u.manager_type = 'ADMIN'

  raise u.errors.to_json unless u.valid?

  u.save
end

ManagerDriver.all.delete_all

# 3: Assign drivers to managers
Spreadsheet.client_encoding = 'UTF-8'

book = Spreadsheet.open "#{Rails.root}/db/line_reports.xls"
sheet1 = book.worksheet 'Drivers'

current_manager = nil

sheet1.each 1 do |row|
  u = User.where('email ilike ?', row[1]).take

  raise 'User not found '+ row[1] if u.nil?

  if row[0].nil?
    md = ManagerDriver.create(:driver_id => u.id, :manager_id => current_manager.id)
  elsif row[0] == 'manager'
    current_manager = User.where('email ilike ? and is_line_manager = true', row[1]).take
  end

  raise 'Manager is nil' if current_manager.nil?
end
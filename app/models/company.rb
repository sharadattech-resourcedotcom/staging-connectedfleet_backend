class Company < ActiveRecord::Base
  has_many :users
  has_many :appointments
  has_many :branches, :class_name => 'Branch', :foreign_key => 'company_id'
  has_one :settings

  def self.create(company)
    salt = BCrypt::Engine.generate_salt

    c = Company.new
    c.name = company[:name]
    c.address  = company[:address]
    c.phone  = company[:phone]
    c.login = company[:login]
    c.salt  = salt
    c.password = c.encrypt_password(company[:password], salt)
    c.save
    Settings.create(c.id)
    User.create({first_name: c.name, last_name: 'Company', on_trip: false, email: c.login, password: company[:password], role_description: 'Company Head', phone: c.phone}, c.id)
    c
  end

	def manufacturers
		mans = Manufacturer.where("company_id = ? OR company_id IS NULL", self.id).order("description ASC")
		models = (mans.length > 0) ? Model.where("manufacturer_id IN (?)", mans.map{|x| x.id}) : []

		return mans, models
	end

  def encrypt_password(pass, salt)
    return Digest::SHA512.hexdigest(pass + ' ' + salt)
  end

  def jobs
    return Job.eager_load(:appointment).where("appointments.company_id = ?", self.id)
  end

  def as_json(options={})
      super(:only => [:id, :name, :address, :phone, :enabled_inspections, :enabled_hours_payroll])
  end

    def self.cron_job
        Company.all.each do |company|
            MailSender.send_emails_about_inspection_job_complete(company.id)
        end
    end


    def create_company_vehicles_based_on_trips
        users_ids = User.company_users_ids(self.id)
        trips = Trip.where(:user_id => users_ids).where(:vehicle_id => nil)
        unknown_model = Model.where(:description => "Unknown").take
        unknown_manufacturer = Manufacturer.where(:description => "Unknown").take
        trips.each do |trip|
            vehicle = Vehicle.get_by_registration(trip.vehicle_reg_number)

            if vehicle.nil?
                vehicle = Vehicle.new
                vehicle.company_id = self.id
                vehicle.manufacturer_id = unknown_manufacturer.id
                vehicle.model_id = unknown_model.id
                vehicle.registration = trip.vehicle_reg_number
                if vehicle.valid?
                    vehicle.save!
                    trip.update_attribute(:vehicle_id, vehicle.id)
                else
                    puts "INVALID VEHICLE"
                end

            else
                trip.update_attribute(:vehicle_id, vehicle.id)
            end
        end
    end

end

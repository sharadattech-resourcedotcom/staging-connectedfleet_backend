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

    def self.remove_company(company_id, company_name, email, password)
        user = User.authenticate(email, password)
        if !user || !user.is_admin
            return "Fail! Admin access required!"
        end

        company = Company.find(company_id)
        if !company
            return "Company not found!"
        end

        if company.name != company_name
            return "Wrong company_name or company_id!"
        end

        ActiveRecord::Base.transaction do
            #STEP 1
            Settings.where(:company_id => company.id).delete_all
            CompanyEmail.where(:company_id => company.id).delete_all
            AppVersion.where(:company_id => company.id).delete_all
            SalesStaff.where(:company_id => company.id).delete_all

            appointments = Appointment.where(:company_id => company.id)
            appointments_ids = appointments.pluck(:id)
            jobs = Job.where("appointment_id IN (?)", appointments_ids)
            jobs_ids = jobs.pluck(:id)
            inspections = MobileInspection.where("job_id IN (?)", jobs_ids)
            inspections_ids = inspections.pluck(:id)
            DamageCollection.where("mobile_inspection_id IN (?)", inspections_ids).delete_all
            DamageItem.where("mobile_inspection_id IN (?)", inspections_ids).delete_all
            inspections.delete_all
            jobs.delete_all
            appointments.delete_all
            Product.where(:company_id => company_id).delete_all
            InsuranceCompany.where(:company_id => company_id).delete_all

            #STEP 2
            users = User.where(:company_id => company_id)
            users_ids = users.pluck(:id)
            UserVehicle.where("user_id IN (?)", users_ids).delete_all
            ApiToken.where("user_id IN (?)", users_ids).delete_all
            ApiLogger.where("user_id IN (?)", users_ids).delete_all
            ManagerDriver.where("manager_id IN (?) OR driver_id IN (?)", users_ids, users_ids).delete_all
            Token.where("user_id IN (?)", users_ids).delete_all
            Device.where("user_id IN (?)", users_ids).delete_all
            Point.where("user_id IN (?)", users_ids).delete_all
            Payroll.where("user_id IN (?)", users_ids).delete_all
            MobileLog.where("user_id IN (?)", users_ids).delete_all
            UserPermission.where("user_id IN (?)", users_ids).delete_all

            trips = Trip.where("user_id IN (?)", users_ids)
            trips_ids = trips.pluck(:id)
            TripStat.where("trip_id IN (?)", trips_ids).delete_all
            trips.delete_all
            Period.where("user_id IN (?)", users_ids).delete_all
            disposals = DisposalInspection.where("user_id IN (?)", users_ids)
            DisposalPhoto.where("disposal_inspection_id IN (?)", disposals.pluck(:id)).delete_all
            disposals.delete_all
            DriverType.where(:company_id => company.id).delete_all
            users.delete_all

            #STEP 3
            Vehicle.where(:company_id => company.id).delete_all
            # Model.where(:company_id => company.id).delete_all
            # Manufacturer.where(:company_id => company.id).delete_all
            company.delete
            return company.name + " company no longer exist in the system!" 
        end
    end

end

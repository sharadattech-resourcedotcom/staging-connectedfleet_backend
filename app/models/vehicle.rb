class Vehicle < ActiveRecord::Base
	belongs_to :manufacturer
	belongs_to :model
    has_many :trips

	validates_presence_of :model_id, :manufacturer_id#, :except => [:create_blank_with_registration]
    validates_presence_of :registration
    validates :registration, :uniqueness => true
    validates_format_of :registration, :with => /\A[A-Z0-9]*\z/, message: "may contain only big letters and digits."

    REGISTRATION_REGEX = /^[A-Z0-9]*$/

	def make_and_model
        txt = []
        txt.push(self.manufacturer.description) unless self.manufacturer.nil?
        txt.push(self.model.description) unless self.model.nil?

        return txt.join(' - ')
    end

    def self.get_by_registration(registration)
        registration = registration.gsub(/\W/ , "").upcase
        return Vehicle.where(:registration => registration).take
    end

    

    def self.create_blank_with_registration(registration, company_id)
        v = Vehicle.new
        v.registration = registration
        v.company_id = company_id
        v.manufacturer_id = Manufacturer.where(:description => "Unknown").take.id
        v.model_id = Model.where(:description => "Unknown").take.id
        v.fix_registration
        if v.valid?
            v.save!
        end
        return v
    end

    def fix_vehicle
        match = REGISTRATION_REGEX.match(self.registration)
        if match.nil? || ( match.length == 1 && match[0] == '' )
            fixed_reg = self.registration.gsub(/\W/ , "").upcase
            vehicle = Vehicle.where(:registration => fixed_reg).take
            if vehicle.nil?
                self.update_attributes(:registration => fixed_reg)
                Trip.where(:vehicle_id => self.id).update_all(:vehicle_reg_number => self.registration)
            elsif self.id != vehicle.id
                Trip.where(:vehicle_id => self.id).update_all(:vehicle_id => vehicle.id, :vehicle_reg_number => vehicle.registration)
                Appointment.where(:vehicle_id => self.id).update_all(:vehicle_id => vehicle.id)
                UserVehicle.where(:vehicle_id => self.id).update_all(:vehicle_id => vehicle.id)
                MobileInspection.where(:vehicle_id => self.id).update_all(:vehicle_id => vehicle.id)
                self.destroy!
            end
        end
    end

    def fix_registration
        if !self.valid?
            self.registration = self.registration.gsub(/\W/ , "").upcase
        end
        return self
    end

	def as_json(options = { })
    super((options || { }).merge({
        :methods => [:make_and_model],
        :include => [:manufacturer, :model]
    }))
  end
end
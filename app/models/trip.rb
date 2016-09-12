class Trip < ActiveRecord::Base
  has_many :points
  belongs_to :user
  belongs_to :period
  belongs_to :vehicle
  has_one :trip_stat
  
  validates_presence_of :start_mileage, :start_date,
    :start_lat, :start_lon, :vehicle_reg_number, :period_start_date, :user_id, :status
  validates_presence_of :end_mileage, :end_date, :if => "status == 'finished'"

  def duration
    return ((self.end_date - self.start_date)/1.hour) if !self.end_date.nil? && !self.start_date.nil?
    return 0
  end

  def safe_end_date
    return '-' if (self.end_date.nil?)
    return self.end_date.in_time_zone('London').strftime("%d/%m/%Y %H:%M")
  end

  def mileage
    return 0 if self.start_mileage.nil? || self.end_mileage.nil?
    return self.end_mileage - self.start_mileage
  end

  def next_trip
    return self.period.trips.where('start_date >= ? AND id <> ?', self.end_date, self.id).order('start_date ASC').first
  end
  
  def previous_trip
    return self.period.trips.where('end_date <= ? AND id <> ?' , self.start_date, self.id).order('start_date DESC').first
  end

  def check_vehicle
    if self.vehicle.nil?
      self.vehicle = Vehicle.where(:registration => self.vehicle_reg_number).take
      if self.vehicle.nil?
        self.vehicle = Vehicle.create_blank_with_registration(self.vehicle_reg_number, self.user.company_id)
      else
        self.vehicle.fix_vehicle
      end
      self.vehicle_reg_number = self.vehicle.registration
      self.save!
    else
      self.vehicle.fix_vehicle
    end
  end

  def vehicle_next_trip
    self.check_vehicle
    return self.vehicle.trips.where('start_date >= ? AND id <> ?', self.end_date, self.id).order('start_date ASC').first
  end
  
  def vehicle_previous_trip
    self.check_vehicle
    return self.vehicle.trips.where('end_date <= ? AND id <> ?' , self.start_date, self.id).order('start_date DESC').first
  end

    def calculate_mileages
        self.check_vehicle
        if self.previous_trip.nil?
          begin
            if self.period.previous_period.last_trip.vehicle_id == self.vehicle_id
              self.private_mileage = self.start_mileage - self.period.start_mileage
            else
              self.private_mileage = 0
            end
          rescue => ex
            self.private_mileage = 0
            puts ex
          end
        elsif !self.vehicle_previous_trip.nil? && !self.vehicle_previous_trip.end_mileage.nil?
            self.private_mileage = self.start_mileage - self.vehicle_previous_trip.end_mileage
        else
            self.private_mileage = 0
        end
        if self.end_mileage.present?
            self.mileage = self.end_mileage - self.start_mileage
        else
            self.mileage = nil
        end
        if self.valid?  
            self.save!
        end
    end

  def transfer_to_period(new_period_id)
    ActiveRecord::Base.transaction do
      old_period_id = self.period_id
      self.update_attribute(:period_id, new_period_id)
      self.update_attribute(:period_start_date, Period.where("id = ?", new_period_id).take.start_date)
      self.fix_mileage
      Period.find(old_period_id).refresh_mileage
    end
  end

  def fix_mileage
    self.calculate_mileages
    self.next_trip.calculate_mileages if self.next_trip.present?
  end

  def get_previous_periods(number)
    periods = [];
    prev_period = self.period

    number.times do
      if prev_period.nil?
      else
        prev_period = prev_period.previous_period
        periods.push(prev_period)
      end
    end
    return periods
  end

  def geocode_start_end_location
    if self.start_location.nil? || self.start_location.to_s == "\-"
      self.geocode_start_location
    end
    if self.end_location.nil? || self.end_location.to_s == "\-"
      self.geocode_end_location
    end
  end

  def geocode_start_location
    require 'geocoder' 
    if self.start_lat == 0 || self.start_lon == 0 || self.start_lat.nil? || self.start_lon.nil?
    else
      query = self.start_lat.to_s + "," + self.start_lon.to_s 
      result = Geocoder.search(query).first 
      if !result.nil?
        ActiveRecord::Base.transaction do
          self.start_location = result.formatted_address
          save!
        end
      end
    end
  end

  def geocode_end_location
    require 'geocoder' 
     if self.end_lat == 0 || self.end_lon == 0 || self.end_lat.nil? || self.end_lon.nil?
    else
      query = self.end_lat.to_s + "," + self.end_lon.to_s 
      result = Geocoder.search(query).first 
      if !result.nil?
        ActiveRecord::Base.transaction do
          self.end_location = result.formatted_address
          save!
        end
      end
    end
  end
  
end
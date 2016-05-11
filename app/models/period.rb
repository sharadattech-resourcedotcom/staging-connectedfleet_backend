class Period < ActiveRecord::Base
has_many :trips
has_many :vehicles, through: :trips
belongs_to :user, :class_name => 'User', :foreign_key => 'user_id'

    def previous_period
        return Period.where("user_id = ? AND end_date <= ? AND id <> ?", self.user_id, self.start_date, self.id).order('end_date DESC').first
    end

    def last_trip #sic! returning trip with end_date==nil in first place
        return self.trips.order('end_date DESC').first
    end

    def first_trip
        return self.trips.order('end_date ASC').first
    end

    def next_period
        if self.status == 'opened' || self.status == 'N/A'
            return nil
        else
            period = Period.where("user_id = ? AND start_date >= ?  AND id <> ?", self.user_id, self.end_date, self.id).order('start_date ASC').first
            if period.nil?
                return nil
            else
                return period
            end 
        end
    end

    def vehicles_ids
        vehs_ids = []
        self.trips.each do |trip|
            vehs_ids.push(trip.vehicle_id) if !vehs_ids.include?(trip.vehicle_id) && !trip.vehicle_id.nil?
        end
        return vehs_ids
    end

    # def vehicles
    #     ids = self.vehicles_ids
    #     return [] if ids.nil? || ids.empty?
    #     return Vehicle.where("id IN (?)", self.vehicles_ids)
    # end

    def first_trip_by_vehicle(vehicle)
        vehicle = vehicle.id if !vehicle.kind_of?(Integer)
        return self.trips.where("vehicle_id = ? AND end_date IS NOT NULL", vehicle).order('end_date ASC').first
    end

    def last_trip_by_vehicle(vehicle)
        vehicle = vehicle.id if !vehicle.kind_of?(Integer)
        return self.trips.where("vehicle_id = ? AND end_date IS NOT NULL", vehicle).order('end_date DESC').first
    end

    def privete_mileage_by_vehicle(vehicle)
        mileage = 0
        vehicle = vehicle.id if !vehicle.kind_of?(Integer)
        trips = self.trips.where("vehicle_id = ? AND end_date IS NOT NULL", vehicle).order('end_date ASC')
        
        trips.each do |trip|
            mileage = mileage + trip.private_mileage
        end

        if self.last_trip_by_vehicle(vehicle).id == self.last_trip.id && !self.end_mileage.nil?
            mileage = mileage + self.end_mileage - trips.last.end_mileage
        end

        return mileage
    end

    def business_mileage_by_vehicle(vehicle)
        mileage = 0
        vehicle = vehicle.id if !vehicle.kind_of?(Integer)
        trips = self.trips.where("vehicle_id = ? AND end_date IS NOT NULL", vehicle).order('end_date ASC')
        
        trips.each do |trip|
            mileage = mileage + trip.mileage
        end

        return mileage
    end

    def driver
        return self.user.full_name
    end

    def refresh_mileage
        trips = self.period_trips.where("status = 'finished' OR status = 'N/A'")
        if (trips.nil? || trips.empty?)
            return {:business => 0, :private => 0 }
        end
        self.private_mileage = 0
        self.business_mileage = 0

        trips.each do |t|
            t.calculate_mileages
            self.private_mileage = self.private_mileage + t.private_mileage
            self.business_mileage = self.business_mileage + t.mileage
        end
        if self.status == 'closed' && !self.last_trip.end_mileage.nil? && self.last_trip.end_mileage < self.end_mileage
            self.private_mileage = self.private_mileage + (self.end_mileage - self.last_trip.end_mileage)
        end
        unless self.valid?
            puts self.errors.to_json
        end
        self.save 
    end

    def overall_mileage
        return {:business => self.business_mileage, :private => self.private_mileage }
    end

    def period_trips
        return Trip.where("period_id = ?" , self.id).order('trips.id DESC')
    end

    def fix_period_trips
        it = 0
        if self.status == 'closed'
            self.trips.each do |trip|
                if trip.start_date > self.end_date
                    if !self.next_period.nil?
                        trip.transfer_to_period(self.next_period.id) 
                        it = it + 1
                    end
                end
            end
            return it
        end
        return 0
    end

    def close(end_mileage, agent_email, closedby, period_end_date)
        ActiveRecord::Base.transaction do
            self.end_mileage = end_mileage
            self.end_date = period_end_date
            self.status = 'closed'
            self.agent_email = agent_email
            self.closed_by = closedby
            self.approved = false
            self.approve_token = generate_token

            if self.valid?
                self.save
                self.refresh_mileage
                MailSender.send_email_about_closed_period(self)
                Period.create(self.user_id, end_mileage, self)
                return true
            else
                return false
            end
        end
    end 

    def can_be_approved_by(user, check_period)
        if user.nil? 
            puts 'User is nil'
            return "[ER.04] Period can't be approved by given agent"
        end

        if self.user.id == user.id
            puts 'Cant be owner of period'
            return "[ER.05] Period can't be approved by given agent"
        end

        if self.user.company.id != user.company.id
            puts 'Different company'
            return "[ER.06] Period can't be approved by given agent"
        end

        if !user.can('approve periods')
            puts 'Not a line manager'
            return "[ER.07] Period can't be approved by given agent"
        end

        if check_period
            if self.status != 'closed'
                puts 'User is nil'
                return "[ER.08] Period can't be approved by given agent"
            end

            if self.approved == true
                return "[ER.09] Period can't be approved by given agent"
            end

            if self.agent_email.downcase != user.email.downcase
                return "[ER.10] Period can't be approved by given agent"
            end
        end
        return true    
    end

    def normalized_start_date
        return self.start_date.strftime("%FT%T.%LZ");  
    end

    def normalized_end_date
        return self.end_date.strftime("%FT%T.%LZ");  
    end

    def email_variables
        agent = User.where(:email => self.agent_email).take
        return_data = {}
        return_data[:DRIVER_NAME] = self.driver
        return_data[:AGENT_EMAIL] = self.agent_email 

        unless agent.nil?
            return_data[:AGENT_NAME] = self.agent_email.nil? ? '--' : agent.full_name
        end

        return_data[:PERIOD_START_DATE] = self.normalized_start_date
        return_data[:PERIOD_END_DATE] = self.end_date.nil? ? '--' : self.normalized_end_date
        return_data[:PERIOD_PRIVATE_MILEAGE] = self.private_mileage
        return_data[:PERIOD_BUSINESS_MILEAGE] = self.business_mileage
        return_data[:PERIOD_ID] = self.id
        return_data[:APPROVE_LINK] = self.approve_token.nil? ? "Error! Can't find approve token." : 'http://connectedfleet.com/#approve/'+ self.id.to_s + '/' + self.approve_token

        return return_data
    end

    def generate_token
        o = [('a'..'z'), ('A'..'Z')].map { |i| i.to_a }.flatten
        return (0...50).map { o[rand(o.length)] }.join
    end 

    ##############STATIC METHODS##############################
    def self.create(user_id, start_mileage, old_period = nil)
        p = Period.new
        p.user_id = user_id
        p.start_date = Time.now.getutc

        if old_period
            p.start_date = old_period.end_date.getutc
        end

        p.status = 'opened'
        p.approved  = false
        p.closed_by = ''
        p.reminder_status = ''
        p.start_mileage = start_mileage
        p.closing_token = Digest::SHA1.hexdigest([Time.now, rand].join)
        p.save

        if old_period
            begin
                puts '------------------- xxx -------------------'
                old_period.period_trips.where('start_date > ?', Time.parse(p.start_date.iso8601).strftime("%F %T")).update_all(:period_start_date => p.start_date, :period_id => p.id)
            rescue => ex
                puts '-----------------------'
                puts 'exception -------------'
                puts ex.to_s
            end
        end
    end

    def self.getLastPeriods(user_id, number)
        periods = Period.where("user_id = ?", user_id).order('start_date DESC').limit(number)
        return periods
    end

    def self.refresh_user_mileages(user_id)
        periods = Period.where("periods.user_id = ?", user_id).eager_load(:trips)
        periods.each do |p|
            p.refresh_mileage
        end
    end

    def self.closePeriodByToken(params)
        begin
            period = Period.where("closing_token = ?", params[:token]).take
            if period.nil?
                raise "Invalid token."
            end
            
            if params[:end_date].nil?
                params[:end_date]= params[:end_day] + '/' + params[:end_month] + '/' + params[:end_year] 
            end
            parsed_date = Date.parse(params[:end_date])

            datetime = parsed_date.strftime('%Y-%m-%d 23:59:59')
            if period.start_date > parsed_date
                raise "End date can't be eariler than start date"
            end

            if period.start_mileage > params[:end_mileage].to_i
                if period.last_trip.vehicle_reg_number == period.first_trip.vehicle_reg_number
                    raise "End mileage can't be lower than start mileage"
                end
            end
            if !User::EMAIL_REGEX.match(params[:agent_email])
                raise "Agent email is incorrect. Please check it once again"
            end

            manager = User.where('lower(email) = ?', params[:agent_email].downcase).take
            canbe = period.can_be_approved_by(manager, false)

            unless canbe == true
                raise canbe
            end
            user = User.find(period.user_id)
            ManagerDriver.change_driver_manager(user, manager)
            res = period.close(params[:end_mileage], params[:agent_email].downcase, 'token', Time.parse(datetime).getutc)
            unless res
                raise period.errors.to_json
            end

            return {:status => true}
        rescue => exception
            puts exception.backtrace
            return {:status => false, :errors =>exception.message}
        end
    end

    def self.generate_closing_tokens
        Period.where(:status => 'opened').each do |period|
            period.closing_token = Digest::SHA1.hexdigest([Time.now, rand].join)
            period.save
        end
    end

    def self.find_by_startdate(datetime, user_id)
        query = "to_char(start_date, 'YYYY-MM-DD HH24:MI:SS') = ?"
        unless user_id.nil?
            query << ' AND user_id = ' + user_id.to_s
        end
        return Period.where(query, Time.parse(datetime).strftime("%F %T")).take
    end

    def self.parse_datetime_api(datetime)
        datetime = datetime.gsub('T', ' ')
        datetime = datetime[0, datetime.index('.')]
        return datetime
    end   

    def self.fix_last_month_periods(company_id = nil)
        # date = Date.today - 1.month
        # date = date.change(day: 15)
        date = Date.new(2015,10,28)
        puts date
        it = 0
        if company_id.nil?
            Period.where("end_date >= ?", date).each do |period|
                it = it + period.fix_period_trips
            end
        else
            Period.joins(:user).where("periods.end_date >= ? AND users.company_id = ?", date, company_id).each do |period|
                it = it +  period.fix_period_trips
            end
        end
        return it
    end

    def self.assign_id_to_trips(date_from)
        Trip.where("period_id IS ? AND start_date >= ?",nil, date_from).each do |t|
            p = Period.where("user_id = ? AND start_date = ?", t.user_id, t.period_start_date).first
            t.update_attribute :period_id, p.id
        end
    end

    def self.first_trip_by_vehicle(vehicle, period_trips)
        vehicle = vehicle.id if !vehicle.kind_of?(Integer)
        return period_trips.select{|t| t.vehicle_id == vehicle && !t.end_date.nil?}.sort_by!{|t| t.end_date}.first
    end

    def self.last_trip_by_vehicle(vehicle, period_trips)
        vehicle = vehicle.id if !vehicle.kind_of?(Integer)
        return period_trips.select{|t| t.vehicle_id == vehicle && !t.end_date.nil?}.sort_by!{|t| !t.end_date}.first
    end

    def self.privete_mileage_by_vehicle(vehicle, period_trips)
        period_trips = period_trips.sort_by!{|t| t.end_date}
        mileage = 0
        vehicle = vehicle.id if !vehicle.kind_of?(Integer)
        trips = period_trips.select{|t| t.vehicle_id == vehicle && !t.end_date.nil?}.sort_by!{|t| t.end_date}
        
        trips.each do |trip|
            mileage = mileage + trip.private_mileage
        end

        if Period.last_trip_by_vehicle(vehicle, period_trips).id == period_trips.last.id && !period_trips.last.period.end_mileage.nil?
            mileage = mileage + period_trips.last.period.end_mileage - trips.last.end_mileage
        end

        return mileage
    end

    def self.business_mileage_by_vehicle(vehicle, period_trips)
        mileage = 0
        vehicle = vehicle.id if !vehicle.kind_of?(Integer)
        trips = period_trips.select{|t| t.vehicle_id == vehicle && !t.end_date.nil?}.sort_by!{|t| t.end_date}
        
        trips.each do |trip|
            mileage = mileage + trip.mileage
        end

        return mileage
    end

    def to_json(options={})
        super(:only => [:id, :user_id, :start_date, :end_date, :status, :start_mileage, :end_mileage, :closed_by, :approved, :reminder_status, :agent_email], :methods => [:overall_mileage])
    end

    def as_json(options={})
        super(:only => [:id, :user_id, :start_date, :end_date, :status, :start_mileage, :end_mileage, :closed_by, :approved, :reminder_status, :agent_email], :methods => [:overall_mileage, :driver])
    end 

end
class DriversController < ApplicationController

  before_filter :authorize_user, :except => [:approve_period, :approve, :list, :create, :changepasswords, :fetchPeriodsToApprove,
                                             :periodToApproveDetails, :approvePeriodByToken, :index, :closePeriodByToken]

  def current_date
    return Date.today
  end
  
  def authorize_user
    if !params[:driver_id].nil?
        if @session_user.id.to_s != params[:driver_id].to_s
          if @session_user.can("see other users")
            if @session_user.role.access_level >= 8
              if @session_user.company_id != User.where(:id => params[:driver_id]).take.company_id
                return render :json => { :status => false, :errors => ["Authorization failed"], :data => {}}
              end
            else
              if !@session_user.is_user_manager(params[:driver_id])
                return render :json => { :status => false, :errors => ["Authorization failed"], :data => {}}
              end
            end
          else
            return render :json => { :status => false, :errors => ["Authorization failed"], :data => {}}
          end
        end
    else
        if @session_user.id != params[:driver][:id] && !params[:driver][:id].nil?
          if @session_user.can("see other users")
            if @session_user.role.access_level >= 8
              if @session_user.company_id != User.where(:id => params[:driver][:id]).take.company_id
                return render :json => { :status => false, :errors => ["Authorization failed"], :data => {}}
              end
            else
              if !@session_user.is_user_manager(params[:driver][:id])
                return render :json => { :status => false, :errors => ["Authorization failed"], :data => {}}
              end
            end
          else
            return render :json => { :status => false, :errors => ["Authorization failed"], :data => {}}
          end
        end
    end
  end

  def create
    params[:driver][:on_trip] = false
    params[:driver][:role_id] = Role.where(:description => 'Driver').take.id
    d = User.create(params[:driver], @session_user.company_id)
    if d.valid?
      return render :json => {:status => true, :errors => [], :data => {}}
    else
      return render :json => {:status => false, :errors => [d.errors.full_messages], :data => {}}
    end
  end

  def getCurrentPeriod
    #user = User.where(:id => params[:driver_id])
    period = nil
    period = Period.where("user_id = ? AND status = 'opened' ", params[:driver_id]).take       
    unless period.nil?
      period.refresh_mileage
    end
    return render :json => { :status => true, :errors => [], :data => {:period =>period }}
  end

  def changePeriodStartMileage
    period = Period.find(params[:period][:id])
    start_mileage = period.start_mileage
    period[:start_mileage] = params[:period][:start_mileage]
    period.save

    sl = SystemLogger.create(
        :user_id => @session_user.id,
        :event_type => SystemLogger::EVENT_TYPES['PERIOD_UPDATE'],
        :description => 'start mileage changed '+ period.normalized_start_date,
        :old_value => start_mileage.to_s,
        :connected_id => period.user_id,
        :new_value => params[:period][:start_mileage]
    )
    sl.save

    return render :json => { :status => true, :errors => [], :data => {}}
  end

  def reopenPeriod
    ActiveRecord::Base.transaction do
      period_to_reopen = Period.where("id = ?", params[:period_id]).first
      period_to_delete = period_to_reopen.next_period

      period_to_delete.trips.each do |t|
        t.transfer_to_period(period_to_reopen.id)
      end

      period_to_reopen.update_attribute(:status, 'opened')
      period_to_reopen.update_attribute(:end_date, nil)
      period_to_reopen.update_attribute(:end_mileage, nil)
      period_to_delete.destroy
    end
    return render :json => {:status => true, :errors => [], :data => {}}
  end

  def getClosedPeriods
    periods = Period.where("user_id = ? AND status != 'opened' ", params[:driver_id])
    periods = periods.take(periods.size)
    return render :json => {:status => true, :errors => [], :data => {:periods => periods}}
  end

    def fetchPeriodsToApprove
        periods = Period.where("status = 'closed' AND approved = false")
        periods = periods.where(:user_id => ManagerDriver.manager_drivers_ids(@session_user.company, @session_user))
        return render :json => {:status => true, :errors => [], :data => {:periods => periods}}
    end

  def fetchPeriod
    period = Period.where(:id => params[:period_id]).take
    return render :json => {:status => true, :errors => [], :data => {:period => period}}
  end

  def createPeriod
    period = Period.where("user_id = ? AND status = 'opened' ",params[:driver_id]).take
    if(period == nil)
      period = Period.create(params[:driver_id],params[:start_mileage])
    end
    return render :json => {:status => true, :errors => [], :data => {:period => period}}
  end

  def closePeriod
    user = User.where('id = ?', params[:driver_id]).take

    if user.nil?
      raise "User wasn't found"
    end

    begin
      # Fetch period
      period = Period.where("user_id = ? AND status = 'opened' AND id = ?  ", params[:driver_id], params[:period][:id]).take
      
      if period.nil?
        raise "Period wasn't found"
      end

      parsed_date = Date.parse(params[:period_end_date])
      datetime = parsed_date.strftime('%Y-%m-%d 23:59:59')

      if period.start_date > parsed_date
        raise "End date can't be eariler than start date"
      end
      # Check agent email and end mileage
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
      
      closedby = (period.user_id == @session_user.id) ? 'agent' : 'driver'

      # raise user.to_json + manager.to_json

      ManagerDriver.change_driver_manager(user, manager)

      res = period.close(params[:end_mileage], params[:agent_email].downcase, closedby, Time.parse(datetime).getutc)

      unless res
        raise period.errors.to_json
      end

      sl = SystemLogger.create(
          :user_id => @session_user.id,
          :event_type => SystemLogger::EVENT_TYPES['PERIOD_CLOSED'],
          :description => 'Period closed '+ period.normalized_start_date,
          :connected_id => period.user_id,
          :old_value => '',
          :new_value => ''
      )
      sl.save
      
      return render :json => {:status => true, :errors => [], :data => {}}
    rescue => exception
      puts exception.backtrace
      return render :json => {:status => false, :errors =>[exception.message], :data => {}}
    end
  end

    def closePeriodByToken #GET
        # user = User.where('id = ?', params[:driver_id]).take
        # if user.nil?
        #     raise "User wasn't found"
        # end
        begin
            period = Period.where("closing_token = ?", params[:token]).take
            if period.nil?
                raise "Invalid token."
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
            ManagerDriver.change_driver_manager(period.user, manager)
            res = period.close(params[:end_mileage], params[:agent_email].downcase, 'driver', Time.parse(datetime).getutc)
            unless res
                raise period.errors.to_json
            end

            return render :json => {:status => true, :error => '', :data => {}}
        rescue => exception
            puts exception.backtrace
            return render :json => {:status => false, :error => exception.message, :data => {}}
        end
    end

  def approve_period
   #1)
      previous_month = self.current_date - 1.month
      @success = false
      @error = nil

    begin

      period = Period.where("user_id = ? AND status = 'closed' AND to_char(start_date, 'YYYY-MM-DD HH24:MI:SS') = ? AND approved = FALSE ", params[:user_id], Time.parse(params[:start_date]).strftime("%F %T")).take

      if period.nil?
        raise "[ER.11] Period couldn't be approved."
      end

      if period.approve_token != params[:t]
        raise "[ER.14] Period couldn't be approved"
      end

      period.approved = true
      period.save

      sl = SystemLogger.create(
          :user_id => 0,
          :event_type => SystemLogger::EVENT_TYPES['PERIOD_APPROVED'],
          :description => 'Period approved'+ period.normalized_start_date,
          :connected_id => period.user_id,
          :old_value => '',
          :new_value => ''
      )
      sl.save

      MailSender.send_email_about_approved_period(period)
      @success = true
      
    rescue => exception
      @error = exception.message
    end   
  end
  
  def approve
    errors = []
    period = Period.where(:id => params[:period_id]).take

    if period.nil?
      errors.push("[ER.12] Period couldn't be found")
      return render :json => {:status => false, :errors => errors}
    else
        if period.update_attribute(:approved, true)
            period.refresh_mileage
            return render :json => {:status => true, :errors => [], :data => {}}
        else
            return render :json => {:status => false, :errors => period.errors.full_messages, :data => {}}
        end
    end     
  end

  def list
    drivers_ids = ManagerDriver.manager_drivers_ids(@session_user.company, @session_user)

    if drivers_ids.length == 0
      return render :json => {:status => true, :errors => [], :data => {:drivers => []}}
    end

    if params[:filter] && params[:filter] != ''
      query_string = "%#{params[:filter]}%".downcase
      drivers = User.select(:id, :first_name, :last_name, :branch_id,:email, :company_id, :on_trip, :status)
                    .where("company_id = ? AND active = true AND id IN (" + drivers_ids.join(',') + ") AND ((id = ?) OR (lower(first_name) LIKE ?) OR (lower(last_name) LIKE ?) OR (lower(email) LIKE ?))",
                           @session_user.company_id,
                           params[:filter].to_i,
                           query_string,
                           query_string,
                           query_string)
    else
      if @session_user.is_manager || @session_user.is_admin
        drivers = User.select(:id, :first_name, :last_name, :branch_id,:email, :company_id, :on_trip, :status)
                      .where("(company_id = ? AND active = true AND id IN (" + drivers_ids.join(',') + "))", @session_user.company_id)
      else
        drivers = User.select(:id, :first_name, :last_name, :branch_id, :email, :company_id, :on_trip, :status)
                      .where("(users.id = ?) OR (company_id = ? AND active = true AND id IN (" + drivers_ids.join(',') + "))", @session_user.id, @session_user.company_id)
      end
    end
    drivers = drivers.sort_by { |driver| [driver.last_name, driver.first_name] }
    return render :json => {:status => true, :errors => [], :data => {:drivers => drivers.as_json(:fields => ['id', 'first_name', 'last_name', 'email', 'full_name'])}}
  end
  
  def update
    user = User.where('id = ?', params[:driver][:id]).take
    fields = ['first_name', 'branch_id', 'last_name', 'phone', 'payroll_number', 'email', 'driver_type_id']
    
    fields.each do |f|
      if params[:driver][f]
        user[f] = params[:driver][f] if !params[:driver][f].nil?
      end
    end
    if user.valid?
      user.save
      return render :json => {:status => true, :errors => [], :data => {}}
    else
      return render :json => {:status => false, :errors => [user.errors.full_messages], :data => {}}
    end
  end
  
  def archive
    user = User.find(params[:user_id])
    if user.update_attribute(:active, false)
       return render :json => {:status => true, :errors =>[], :data => {}}
    else
       return render :json => {:status => false, :errors => user.errors.full_messages, :data => {}}
    end
  end

  def changepassword
    if params[:newpassword][:password]!= "" && params[:newpassword][:password] == params[:newpassword][:repeated]
      user = User.where('id = ?', params[:driver_id]).take
      render :json => user.change_password(params[:newpassword][:password], params[:newpassword][:oldpassword], @session_user)
    else
      return render :json => {:status => false, :errors => ['Repeated password do not match'], :data => {}}
    end
  end
  
  def details
    user = User.where('id = ?', params[:driver_id]).take
    if @session_user.can("see security codes")
      user = user.as_json(:additional => ['security_code'])
    else
      user = user.as_json
    end
    return render :json => {:status => true, :errors => [], :data => {:driver => user}}
  end

  def listTrips
    if !params[:period_id].nil?
      trips = Trip.where("period_id = ?", params[:period_id]).order(start_date: :desc) 
    else
      trips = Trip.where("user_id = ?", params[:user_id]).order(start_date: :desc) if !params[:user_id].nil?
    end

    return render :json =>  {:status => true, :errors => [], :data => {:trips => trips}}
  end

  def listInspections
    # if @session_user.role.access_level == 1
    #   inspections = MobileInspection.where(:vehicle_id => UserVehicle.user_vehicles_ids(@session_user.id))
    # else
    inspections = MobileInspection.where(:user_id => params[:driver_id])
    inspections += EstimatorInspection.where(:driver_id => params[:driver_id])
    inspections = inspections.as_json.sort_by {|h| h['created_at']}.reverse unless inspections.empty?
    # end 
    return render :json =>  {:status => true, :errors => [], :data => {:inspections => inspections}}
  end

  def isLastClosedPeriod # if return -1 then checked period is opened
    period = Period.where("id = ?", params[:period_id]).first
    next_period = period.next_period

    if next_period == nil
      ret = -1
    else
      if next_period.status == 'opened'
        ret = true
      else
        ret = false
      end
    end
    return render :json => {:status => true, :errors => [], :data => ret}
  end

    def periodToApproveDetails
        period = Period.where(:id => params[:period_id]).take
        if period.nil?
            return render :json =>  {:status => false, :errors => ['Period does not exist.'], :data => {}}
        end
        if params[:approve_token] == period.approve_token
            trips = Trip.where("period_id = ?", params[:period_id]).order(start_date: :desc) 
            user = User.where(:id => period.user_id).take
            if period.approved
                return render :json =>  {:status => false, :errors => ['This period has already been approved.'], :data => {}}
            else
                return render :json =>  {:status => true, :errors => [], :data => {:period => period, :trips => trips, :driver => user}} 
            end
        else
            return render :json =>  {:status => false, :errors => ['Invalid token.'], :data => {}}
        end
    end

    def approvePeriodByToken
        period = Period.where(:id => params[:period_id]).take
        if params[:approve_token] == period.approve_token
            period.update_attribute(:approved, true)
            return render :json =>  {:status => true, :errors => [], :data => {}} 
        else
            return render :json =>  {:status => false, :errors => ['Invalid token.'], :data => {}}
        end
    end

  def index
    puts params
    if params[:token].nil? || params[:token] == ''
      @error = 'Invalid token.'
      return
    end
    @token = params[:token]
    @period = Period.where("closing_token = ? AND status = 'opened'", @token).take
    if @period.nil?
      @error = 'Invalid token.'
      return
    end

    @days = (1..31).to_a
    if @period.start_date.month > Date.today.month
      @months = [@period.start_date.month, Date.today.month]
    else
      @months = (@period.start_date.month..Date.today.month).to_a
    end
    @years = (@period.start_date.year..Date.today.year).to_a 
  
    if !params[:end_mileage].nil? && !params[:end_day].nil? && !params[:end_month].nil? && !params[:end_year].nil? && !params[:agent_email].nil?
        @end_mileage = params[:end_mileage]
        @agent_email = params[:agent_email]
        return_json = Period.closePeriodByToken(params)
        if return_json[:status]
          @success = "Period has been closed."
        else
          @error = return_json[:errors]
        end
    end
  end
end

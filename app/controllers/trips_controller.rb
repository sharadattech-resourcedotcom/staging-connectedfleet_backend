class TripsController < ApplicationController
  before_filter :authenticate_user

  def list
    if @session_user.can('see other users')              #(can? :listCompanyTrips, TripsController)
      drivers_ids = ManagerDriver.manager_drivers_ids(@session_user.company, @session_user)

      if params[:filter] && params[:filter] != ''
        query_string = "%#{params[:filter]}%".downcase
        trips = Trip.joins(:user)
        .where("users.company_id = ? AND users.id IN (" + drivers_ids.join(',') + ") AND (
                                            (trips.id = ?)
                                            OR (lower(trips.start_location) ILIKE ?)
                                            OR (lower(trips.end_location) ILIKE ?)
                                            OR (to_char(trips.start_date, 'YYYY-MM-DD HH24:MI:SS') ILIKE ?)
                                            OR (to_char(trips.end_date, '%Y-%m-%d %H:%M:%S') ILIKE ?)
                                            OR (CONCAT(users.first_name, ' ', users.last_name) ILIKE ?)
                                            OR (trips.vehicle_reg_number ILIKE ?)
                                          )",
                     @session_user.company_id,
                     params[:filter].to_i,
                     query_string,
                     query_string,
                     query_string,
                     query_string,
                     query_string,
                     query_string)
        .order(start_date: :desc)
      else
        trips = Trip.joins(:user)
        .where(users: {id: drivers_ids, company_id:@session_user.company_id})
        .order(start_date: :desc)
      end
    else
      if params[:filter] && params[:filter] != ''
        query_string = "%#{params[:filter]}%".downcase
        trips = Trip.joins(:user)
        .where("users.id = ? AND (
                                            (trips.id = ?)
                                            OR (lower(trips.start_location) LIKE ?)
                                            OR (lower(trips.end_location) LIKE ?)
                                            OR (to_char(trips.start_date, 'YYYY-MM-DD HH24:MI:SS') LIKE ?)
                                            OR (to_char(trips.end_date, '%Y-%m-%d %H:%M:%S') LIKE ?)
                                          )",
               @session_user.id,
               params[:filter].to_i,
               query_string,
               query_string,
               query_string,
               query_string)
        .order(start_date: :desc)
      else
        trips = Trip.joins(:user)
        .where(users: {id:@session_user.id})
        .order(start_date: :desc)
      end
    end
    trips = trips.joins(:vehicle)
    if !params[:page].nil?
        if params[:page] == 0
            count = trips.count
            params[:page] = 1
        else
            count = nil
        end
        trips = trips.select('trips.*', 'users.id as driver_id', 'vehicles.registration as vehicle_registration', 'users.first_name', 'users.last_name')
        return render :json => {:status => true, :errors => [], :data => {:trips => trips.limit(50).offset((params[:page].to_i - 1)* 50), :count => count}}
    else
        trips = trips.select('trips.*', 'users.id as driver_id', 'users.first_name', 'users.last_name')
        return render :json => {:status => true, :errors => [], :data => {:trips => trips}}
    end
  end

  def details
    trip = Trip.where('trips.id = ?', params[:id]).eager_load(:trip_stat).take
    stats = trip.trip_stat
    #points = Point.where('trip_id = ?', trip.id).order('timestamp asc')
    settings = Settings.find_or_create_by(:company_id => @session_user.company_id)

    next_trip = trip.next_trip
    prev_trip = trip.previous_trip

    last_five_periods = Period.getLastPeriods(Trip.find(params[:id]).user_id, 5)
    
    trip['next'] = next_trip
    trip['prev'] = prev_trip
    
    return render :json => {:status => true, :errors => [], :data => {:trip => trip, :stats => stats, :last_five_periods => last_five_periods,
                     :lines => {:red_value => settings.red_line_value, :orange_value => settings.orange_line_value} }}
  end

  def listPoints
    points = Point.where('trip_id = ?', params[:id]).order(timestamp: :asc)
    return render :json => {:status => true, :errors => [], :data => {:points => points}}
  end

    def download_points_xls
        require 'spreadsheet'
        points = Trip.find(params[:trip_id]).points.order("timestamp ASC")
        book = Spreadsheet::Workbook.new
        sheet = book.create_worksheet :name => 'Points Report'
        sheet.row(0).push "Date"
        sheet.row(0).push "Lat"
        sheet.row(0).push "Lng"
        sheet.row(0).push "BT"
        sheet.row(0).push "Don"
        sheet.row(0).push "Vehicle speed"
        sheet.row(0).push "RPM"
        sheet.row(0).push "Fuel"
        sheet.row(0).push "Beh. Points"

        points.each_with_index do |p, index|
            sheet.row(index+1).push p.timestamp
            sheet.row(index+1).push p.latitude
            sheet.row(index+1).push p.longitude
            sheet.row(index+1).push p.bt
            sheet.row(index+1).push p.dongle
            sheet.row(index+1).push (p.vehicle_speed/1.609).round(0)
            sheet.row(index+1).push p.rpm.round(0)
            sheet.row(index+1).push p.fuel_in_mpg.round(1)
            sheet.row(index+1).push p.behaviour_points
        end
        spreadsheet = StringIO.new
        book.write spreadsheet
        send_data spreadsheet.string, :filename => 'points_report_' + params[:trip_id] + '.xls', :type =>  "application/vnd.ms-excel"

        return spreadsheet
    end

  def refreshPeriodMileage
    #if(can? :refresh_mileage, @session_user)
      Period.where("id = ?", params[:period_id]).take.refresh_mileage
    #end
    return render :json => {:status => true, :errors => [], :data => {}}
  end

  def delete   
    trip = Trip.where('id = ?', params[:trip_id]).take

    return render :json => {:status => false, :errors => ["Trip not found"]} if trip.nil?    
    period = trip.period   
    Point.delete_all("trip_id = " + trip.id.to_s)
    trip.delete   
    period.refresh_mileage
    return render :json => {:status => true, :errors => []}
  end
  # End of Delete trip
  
  
  ###
  # Create trip in given period
  #
  # @param params[:period_start_date] DateTime start date of period
  # @param params[:trip] Object trip object containing trip info
  #
  # @return void|Exception
  #
  def create          
    period_id = params[:period][:id]
        
    # 2) Validate trip correctness (start dates and mileages) 
    t = Trip.new
    t.status = 'finished'
    t.assign_attributes(create_trip_params)
    t.period_start_date = Period.where("id = ?", period_id).first.start_date
    t.period_id = period_id

    if t.start_date > t.end_date
        return render :json => {:status => false, :errors => ['End date must be after the start date!'], :data => {}} 
    end

    t.mileage = t.end_mileage - t.start_mileage if t.end_mileage > 0  

    return render :json => {:status => false, :errors => ['End mileage must be grater than start mileage!'], :data => {}} unless t.mileage >= 0

    if Vehicle.get_by_registration(params[:trip][:vehicle_reg_number]).nil?
        v = Vehicle.create_blank_with_registration(params[:trip][:vehicle_reg_number], @session_user.company_id)
        unless v.valid?
          return render :json => {:status => false, :errors => v.errors.full_messages, :data => {}}
        end
        t.vehicle_reg_number = v.registration
        t.vehicle_id = v.id
    end

    unless t.valid?
      return render :json => {:status => false, :errors => t.errors.full_messages, :data => {}}
    end
    
    t.estimated_time = '0 hours'
    
    # Convert dates because they're added in UK time
    # t.start_date = ActiveSupport::TimeZone.new("Europe/London").local_to_utc(t.start_date).to_s
    # t.end_date   = ActiveSupport::TimeZone.new("Europe/London").local_to_utc(t.end_date).to_s
    t.fix_mileage 
    t.save
    
    # 3) Update period mileages
    Period.where("id = ?", period_id).first.refresh_mileage
    
    return render :json => {:status => true, :errors => [], :data => {}}
  end
  # End of Create Trip
  
  def updateTrip
    return_data = {status: true, success_msg: '<div class="alert alert-success" role="alert">',
                   error_msg: '<div class="alert alert-danger" role="alert"><ul>', data: nil }

    trip = Trip.where(id: params[:trip][:id]).take

    oldvalue = trip.to_json

    begin
      start_date = Time.parse(params[:trip][:start_date])
      end_date = Time.parse(params[:trip][:end_date]) if params[:trip][:status] == 'finished'
    rescue
      return_data[:status]=false
      return_data[:error_msg] << '<li>Wrong time format</li>'
    end

    if !params[:trip][:start_mileage].to_s.is_i? || (params[:trip][:status] == 'finished' && !params[:trip][:end_mileage].to_s.is_i?)
      return_data[:status]=false
      return_data[:error_msg] << '<li>Wrong mileage format</li>'
    else
      start_mileage = params[:trip][:start_mileage].to_s.to_i
      end_mileage = params[:trip][:end_mileage].to_s.to_i if params[:trip][:status] == 'finished'
    end

    if !params[:trip][:start_lat].to_s.is_f? || !params[:trip][:start_lon].to_s.is_f? || params[:trip][:status] == 'finished' && ( !params[:trip][:end_lat].to_s.is_f? || !params[:trip][:end_lon].to_s.is_f? )
      return_data[:status]=false
      return_data[:error_msg] << '<li>Wrong point format</li>'
    end

    if !return_data[:status]
      return_data[:error_msg] << '</ul></div>'
      render :json => return_data
      return
    end

    period = trip.period
    return_data = {status: true, success_msg: '<div class="alert alert-success" role="alert">',
                   error_msg: '<div class="alert alert-danger" role="alert"><ul>', data: nil }

    if params[:trip][:status] == 'finished'
      if start_mileage >= end_mileage
        return_data[:status]=false
        return_data[:error_msg] << '<li>End mileage should be greater than start mileage</li>'
      end

      if start_date >= end_date
        return_data[:status]=false
        return_data[:error_msg] << '<li>Start date should be before end date</li>'
      end
    end
 
    if !return_data[:status]
      return_data[:error_msg] << '</ul></div>'
      render :json => return_data
      return
    end

    if trip[:vehicle_reg_number] != params[:trip][:vehicle_reg_number]
      vehicle = Vehicle.get_by_registration(params[:trip][:vehicle_reg_number])
      if vehicle.nil?
        vehicle = Vehicle.create_blank_with_registration(params[:trip][:vehicle_reg_number], @session_user.company_id)
        unless vehicle.valid?
          return render :json => {:status => false, :errors => vehicle.errors.full_messages, :data => {}}
        end
      end
      trip[:vehicle_reg_number] = vehicle.registration
      trip[:vehicle_id] = vehicle.id
    end

    trip[:start_mileage] = params[:trip][:start_mileage].to_s.to_i 
    trip[:start_lat] = params[:trip][:start_lat].to_s.to_f
    trip[:start_lon] = params[:trip][:start_lon].to_s.to_f
    trip[:start_date] = start_date
    trip[:description] = params[:trip][:description]
    trip[:reason] = params[:trip][:reason]
    trip[:start_location] = params[:trip][:start_location]

    if params[:trip][:status] == 'finished'
      trip[:end_mileage] = params[:trip][:end_mileage].to_s.to_i
      trip[:end_lat] = params[:trip][:end_lat].to_s.to_f
      trip[:end_lon] = params[:trip][:end_lon].to_s.to_f
      trip[:end_date] = end_date
      trip[:end_location] = params[:trip][:end_location]
    end

    if @session_user.can('change trips status')
      trip[:status] = params[:trip][:status]
    end
    
    unless trip.valid? 
      return_data[:status] = false
      return_data[:error_msg] << '<li>' + trip.errors.full_messages.join('</li><li>') + '</li>'
      return render :json => return_data
    end

    trip.fix_mileage    
    trip.save

    sl = SystemLogger.create(
        :user_id => @session_user.id,
        :event_type => SystemLogger::EVENT_TYPES['TRIP_UPDATED'],
        :description  => 'Trip updated',
        :connected_id => trip.id,
        :old_value => oldvalue,
        :new_value => trip.to_json
    )
    sl.save
    
    period.refresh_mileage
    
    return_data[:success_msg] << 'Trip saved successfully</div>'
    
    render :json => return_data
  end
  
  def create_trip_params
    params.require(:trip).permit(:start_location, :end_location, :start_mileage, :end_mileage, :start_date, :end_date, 
    :start_lat, :start_lon, :end_lat, :end_lon, :reason, :vehicle_reg_number, :user_id, :period_start_date)
  end

  def moveToPeriod
      Trip.where("id = ?", params[:trip_id]).first.transfer_to_period(params[:period_id])
      return render :json => {:status => true, :errors => [], :data => {}}
  end
end

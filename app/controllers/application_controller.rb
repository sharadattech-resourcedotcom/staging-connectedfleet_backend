class ApplicationController < ActionController::Base

   layout :nil

  protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }
  before_filter :add_allow_credentials_headers
  before_filter :authenticate_user, :except => [:jenkins_upload_apk, :sign_in, :periodToApproveDetails, :approvePeriodByToken, :closePeriodByToken, :index, :submit]

  def add_allow_credentials_headers 
    response.headers['Access-Control-Allow-Origin'] = '*'
    response.headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, OPTIONS'
    response.headers['Access-Control-Request-Method'] = '*'
    response.headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization, X-Access-Token'

    return render :text => 'OK' if request.method == 'OPTIONS'
  end
  #protect_from_forgery :except => :create
  """rescue_from CanCan::AccessDenied do | exception |
    puts $!
    redirect_to(:controller => 'dashboard', :action => 'index')
  end"""

  def authenticate_user
    controller = request.symbolized_path_parameters[:controller]
    if request.symbolized_path_parameters[:action] == 'download_report_xls' || request.symbolized_path_parameters[:action] == 'download_inspection_pdf' ||
      request.symbolized_path_parameters[:action] == 'download_points_xls'
        user_token = ApiToken.where("access_token = ?", params[:token]).take
    else
      user_token = ApiToken.where("access_token = ?", request.headers["X-Access-Token"]).take
    end  
    if !user_token.nil?
      @session_user = user_token.user
      if controller == 'scheduler' || controller == 'appointments' || controller == 'inspections' 
        if !@session_user.company.enabled_inspections
          return render :json => {:status => false, :errors => ["Authorization failed"]}
        end
      end
      if controller == 'hours_payroll'
        if !@session_user.company.enabled_hours_payroll
          return render :json => {:status => false, :errors => ["Authorization failed"]}
        end
      end
      if !@session_user.authorize(request.symbolized_path_parameters)
        return render :json => {:status => false, :errors => ["Authorization failed"]}
      end
      @session_user.update_attribute(:last_request, Time.current)
    else
      return render :json => {:status => false, :errors => ["Authentication failed"]}
    end
    
  end
  
  def is_signed_in
    return !User.where(:id => session[:user_id]).take.nil?
  end
  
end

class AuthController < ApplicationController

#skip_before_filter :verify_authenticity_token, if: :json_request?
before_filter :add_allow_credentials_headers

  def add_allow_credentials_headers 
    response.headers['Access-Control-Allow-Origin'] = '*'
    response.headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, OPTIONS'
    response.headers['Access-Control-Request-Method'] = '*'
    response.headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization, X-Access-Token'

    return render :text => 'OK' if request.method == 'OPTIONS'
  end

  def sign_in
    @error = nil
    user = params[:user]

    u = User.authenticate(params[:user][:login], params[:user][:password])
    if u 
      if !u.active
        @error = 'This account is deactivated.'
        return render :json => {:status => false, :errors => @error}
      end
      session[:user_id] = u.id

      sl = SystemLogger.create(
          :user_id => u.id,
          :event_type => SystemLogger::EVENT_TYPES['USER_SIGNED_IN'],
          :description => 'User signed in',
          :connected_id => u.id,
          :old_value => '',
          :new_value => ''
      )
      sl.save
      app = AppVersion.where("company_id = ? AND internal_group = ?", u.company_id, u.internal_staff).last
      token = ApiToken.generate(u.id, request.env['REMOTE_ADDR'])
      return render :json => {:status => true, :errors => {}, :data => {:token => token, :user => u, :app => app}}
    else
      @error = 'Invalid email or password'
      return render :json => {:status => false, :errors => @error}
    end
  end
  
  
  def signout
    session[:user_id] = nil
     sl = SystemLogger.create(
            :user_id => u.id,
            :event_type => SystemLogger::EVENT_TYPES['USER_SIGNED_OUT'],
            :description => 'User signed out',
            :connected_id => u.id,
            :old_value => '',
            :new_value => ''
        )
        sl.save
      return render :json => {:status => true, :errors => {}, :data => {}}
  end
  
  
end

class DashboardController < ApplicationController
  before_filter :authenticate_user
  
  def download
    send_file "#{Rails.root}/public/2014_08_27_FlightPath.apk", :type=>"application/apk", :x_sendfile=>true
  end
end

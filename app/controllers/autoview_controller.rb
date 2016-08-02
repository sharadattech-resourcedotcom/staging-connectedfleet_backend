class AutoviewController < ApplicationController
  before_filter :authenticate_user

  def drivers
    if @session_user.role.access_level >= 8
      drivers_ids = ManagerDriver.manager_drivers_ids(@session_user.company, @session_user)
    else
      drivers_ids = ManagerDriver.ids_in_hierarchy(@session_user)
    end
    users = []

    if drivers_ids.length > 0
    	dbusers = User.select('id, first_name, last_name, lat, lng, last_sync, status, active, marker_type').where('id IN (' + drivers_ids.join(',') + ')').order('LOWER(last_name) asc')

      dbusers.each do |d|
        if d.active && !d.last_sync.nil? && d.last_sync > (DateTime.now.utc - 1.hour)
          dict = {:id => d.id, :first_name => d.first_name, :last_name => d.last_name, :lat => d.lat, :lng => d.lng, :status => d.status, :marker_type => d.marker_type}
          dict['last_sync'] = -1
          dict['last_sync'] = ((DateTime.now.utc.to_f - d.last_sync.to_f)/60).round unless d.last_sync.nil?
          users.push(dict)
        end
      end    	
    end
    return render :json => {:status => true, :data => users}
  end
end
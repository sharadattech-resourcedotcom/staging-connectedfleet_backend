
Rails.application.routes.draw do

  #get  '/', to: 'auth#signin'
  #post '/', to: 'auth#signin'  
  
  match "/" => "auth#sign_in", :as => "sign_in", :via => [:get,:post, :options]

      #drivers module actions
          #get  'drivers', to: 'drivers#index', as: 'drivers'
        get 'drivers/closePeriodView', to: 'drivers#index', as: 'close_period_view'
          # post 'drivers/list'
        match '/drivers/list' => 'drivers#list', :as => 'drivers_list', :via => [:post ,:options]
          # post 'drivers/create'
        match '/drivers/create' => 'drivers#create', :as => 'driver_create', :via => [:post ,:options]
          # post 'drivers/update'
        match '/drivers/update' => 'drivers#update', :as => 'driver_update', :via => [:post ,:options]
          # post 'drivers/details'
        match '/drivers/details' => 'drivers#details', :as => 'driver_details', :via => [:post ,:options]
          # post 'drivers/listTrips'
        match '/drivers/listTrips' => 'drivers#listTrips', :as => 'listTrips', :via => [:post ,:options]
        match '/drivers/listInspections' => 'drivers#listInspections', :as => 'listInspections', :via => [:post ,:options]
          # post 'drivers/changepassword'
        match '/drivers/changepassword' => 'drivers#changepassword', :as => 'changepassword', :via => [:post ,:options]
          # post 'drivers/getCurrentPeriod'
        match '/drivers/getCurrentPeriod' => 'drivers#getCurrentPeriod', :as => 'getCurrentPeriod', :via => [:post ,:options]
          # post 'drivers/getClosedPeriods'
        match '/drivers/getClosedPeriods' => 'drivers#getClosedPeriods', :as => 'getClosedPeriods', :via => [:post ,:options]
          # post 'drivers/createPeriod'
        match '/drivers/createPeriod' => 'drivers#createPeriod', :as => 'createPeriod', :via => [:post ,:options]
          # post 'drivers/closePeriod'
        match '/drivers/closePeriod' => 'drivers#closePeriod', :as => 'closePeriod', :via => [:post ,:options]
        
        match '/drivers/closePeriodByToken' => 'drivers#closePeriodByToken', :as => 'closePeriodByToken', :via => [:get ,:options]
          # post 'drivers/updatePeriod'
        match '/drivers/changePeriodStartMileage' => 'drivers#changePeriodStartMileage', :as => 'changePeriodStartMileage', :via => [:post ,:options]
          # post 'drivers/approve_period'  
        match '/drivers/approve_period' => 'drivers#approve_period', :as => 'approve_period', :via => [:post ,:options]
        match '/period_to_approve_details' => 'drivers#periodToApproveDetails', :as => 'period_to_approve_details', :via => [:post ,:options]
        match '/approve_period_by_token' => 'drivers#approvePeriodByToken', :as => 'approve_period_by_token', :via => [:post ,:options]
          # post 'drivers/isLastClosedPeriod', to: 'drivers#isLastClosedPeriod'
        match '/drivers/isLastClosedPeriod' => 'drivers#isLastClosedPeriod', :as => 'isLastClosedPeriod', :via => [:post ,:options]
          # post 'drivers/reopenPeriod', to: 'drivers#reopenPeriod'
        match '/drivers/reopenPeriod' => 'drivers#reopenPeriod', :as => 'reopenPeriod', :via => [:post ,:options]
          # get  'drivers/approve/:user_id/:start_date', to: 'drivers#approve'
        match '/drivers/approve' => 'drivers#approve', :as => 'approve', :via => [:post ,:options]
        match '/drivers/fetchPeriod' => 'drivers#fetchPeriod', :as => 'fetchPeriod', :via => [:post, :options]
        match '/drivers/archive' => 'drivers#archive', :as => 'archiveUser', :via => [:post, :options]
        match '/drivers/fetchPeriodsToApprove' => 'drivers#fetchPeriodsToApprove', :as => 'fetchPeriodsToApprove', :via => [:get, :options]


      #trip module actions
          #get 'trips', to: 'trips#index', as: 'trips'
          #post 'trips/list'
      match "/trips" => 'trips#list', :as => 'trips_list', :via => [:post, :options]
          #post 'trips/details'
      match 'trips/details' => 'trips#details', :as => 'trip_details', :via => [:post, :options]
          #post 'trips/listPoints'
      match 'trips/listPoints' => 'trips#listPoints', :as => 'listPoints', :via => [:post, :options]
      match 'trips/download_points_xls' => 'trips#download_points_xls', :as => 'download_points_xls', :via => [:post, :get, :options]
          #post 'trips/updateTrip'
      match 'trips/updateTrip' => 'trips#updateTrip', :as => 'updateTrip', :via => [:post, :options]
          #post 'trips/delete'
      match 'trips/delete' => 'trips#delete', :as => 'trip_delete', :via => [:post, :options]
          #post 'trips/create'
      match 'trips/create' => 'trips#create', :as => 'trip_create', :via => [:post, :options]
          #post 'trips/refreshPeriodMileage'     
      match 'trips/refreshPeriodMileage' => 'trips#refreshPeriodMileage', :as => 'refreshPeriodMileage', :via => [:post, :options]
          #post 'trips/getLastPeriods', to: 'trips#getLastPeriods', as: 'getlastPeriods'
      match 'trips/getLastPeriods' => 'trips#getLastPeriods', :as => 'getLastPeriods', :via => [:post, :options]
          #post 'trips/moveToPeriod', to: 'trips#moveToPeriod', as: 'moveToPeriod'
      match 'trips/moveToPeriod' => 'trips#moveToPeriod', :as => 'moveToPeriod', :via => [:post, :options]
          #get 'dongle/trip/:id', to: 'dongle#trip'
      match 'dongle/trip/:id' => 'dongle#trip', :as =>'dongle_data', :via => [:get, :options]

      match 'chart_data/trip/:id' => 'dongle#chart_data', :as =>'chart_data', :via => [:get, :options, :post]

          #get 'autoview/index', to: 'autoview#index'
          #get 'autoview/drivers', to: 'autoview#drivers'
      match 'autoview/drivers' => 'autoview#drivers', :as => 'autoview_drivers', :via => [:get, :options]
      
      #reports module actions
           # post 'reports/generate', to: 'reports#generate', as: 'generate'
      match 'reports/generate' => 'reports#generate', :as => 'generate', :via => [:post, :options]
      # get 'reports/generate', to: 'reports#generate', as: 'get_generate'
      match 'reports/download_report_xls' => 'reports#download_report_xls', :as => 'download_report_xls', :via => [:get, :options]
      # get 'reports/list', to: 'reports#list', as: 'list'
      match 'reports/list' => 'reports#list', :as => 'list', :via => [:get, :options]

  #company module actions
  match 'companies/list' => 'companies#list', :as => 'companies_list', :via => [:post, :options]
      #post 'companies/list'
  match 'companies/create' => 'companies#create', :as => 'company_create', :via => [:post, :options]
      #post 'companies/create'
  match 'companies/details' => 'companies#details', :as => 'company_details', :via => [:post, :options]
      #post 'companies/details'
  match 'companies/getCompanyHeads' => 'companies#getCompanyHeads', :as => 'company_heads', :via => [:post, :options]
      #post 'companies/getCompanyHeads'
  match 'companies/getCompanyHead' => 'companies#getCompanyHead', :as => 'company_head', :via => [:post, :options]
      #post 'companies/getCompanyHead'
  match 'companies/createCompanyHead' => 'companies#createCompanyHead', :as => 'company_head_create', :via => [:post, :options]
      #post 'companies/createCompanyHead'
  match 'companies/updateCompanyHead' => 'companies#updateCompanyHead', :as => 'company_head_updatee', :via => [:post, :options]
  match 'companies/updateDetails' => 'companies#updateDetails', :as => 'company_update', :via => [:post, :options]
      #post 'companies/updateCompanyHead'
  match 'companies/changeCompanyHeadPassword' => 'companies#changeCompanyHeadPassword', :as => 'company_head_change_password', :via => [:post, :options]
      #post 'companies/changeCompanyHeadPassword'

  get  'dashboard/download'

  #management panel actions
  match "/upload_apk" => 'management_panel#upload_apk', :as => 'upload_apk', :via => [:post, :options]
  match "/jenkins_upload_apk" => 'management_panel#jenkins_upload_apk', :as => 'jenkins_upload_apk', :via => [:post, :options]
  match "/send_roles" => 'management_panel#save_roles', :as => 'send_roles', :via => [:post, :options]
  match "/new_role" => 'management_panel#new_role', :as => 'new_role', :via => [:post, :options]
  match "/send_user_permissions" => 'management_panel#save_user_permissions', :as => 'send_user_permissions', :via => [:post, :options]
  match "/send_user" => 'management_panel#create_user', :as => 'send_user', :via => [:post, :options]
  match "/fetch_permissions_data" => 'management_panel#fetch_permissions_data', :as => 'fetch_permissions_data', :via => [:get, :options]
  match "/fetch_roles_data" => 'management_panel#fetch_roles_data', :as => 'fetch_roles_data', :via => [:get, :options]
  match "/fetch_settings_data" => 'management_panel#fetch_settings_data', :as => 'fetch_settings_data', :via => [:get, :options]
  match "/fetch_create_user_data" => 'management_panel#fetch_create_user_data', :as => 'fetch_create_user_data', :via => [:get, :options]
  match "/update_settings_data" => 'management_panel#update_settings_data', :as => 'update_settings_data', :via => [:post, :options]
  match "/remove_settings_value" => 'management_panel#remove_settings_value', :as => 'remove_settings_value', :via => [:post, :options]
  match "/fetch_logs" => 'management_panel#fetch_logs', :as => 'logs', :via => [:post, :options]
  match '/synchronize_log' => 'management_panel#synchronize_log', :as => 'synchronize_log', :via => [:post, :options]
  match '/fetch_managers_and_drivers' => 'management_panel#fetch_managers_and_drivers', :as => 'fetch_managers_and_drivers', :via => [:get, :options]
  match '/assign_manager_to_driver' => 'management_panel#assign_manager_to_driver', :as => 'assign_manager_to_driver', :via => [:post, :options]
  match '/management_panel/vehicles_access_users' => 'management_panel#vehicles_access_users', :as => 'vehicles_access_users', :via => [:get, :options]
  match '/management_panel/user_vehicles' => 'management_panel#user_vehicles', :as => 'user_vehicles', :via => [:post, :options]
  match '/management_panel/save_user_vehicles' => 'management_panel#save_user_vehicles', :as => 'save_user_vehicles', :via => [:post, :options]
  match '/management_panel/staff_users' => 'management_panel#fetch_sales_staff', :as => 'sales_stuff', :via => [:post, :get, :options]
  match '/management_panel/save_staff_users' => 'management_panel#save_sales_staff', :as => 'save_sales_stuff', :via => [:post, :options]


  match '/hours_payroll/fetch_drivers_types' => 'hours_payroll#fetch_drivers_types', :as => 'drivers_types', :via => [:post, :get, :options]
  match '/hours_payroll/save_driver_type' => 'hours_payroll#save_driver_type', :as => 'save_driver_type', :via => [:post, :options]


  match '/vehicles/list' => 'vehicles#list', :as => 'vehicles_list', :via => [:post, :options]
  match '/vehicles/create' => 'vehicles#create_vehicle', :as => 'vehicle_create', :via => [:post, :options]
  match '/vehicles/pre_data' => 'vehicles#pre_data', :as => 'vehicles_pre_data', :via => [:get, :options]
  match '/vehicles/:id/details' => 'vehicles#details', :as => 'vehicle_details', :via => [:get, :options]
  match '/vehicles/update' => 'vehicles#update_details', :as => 'vehicle_update', :via => [:post, :options]

  
  match '/appointments/list' => 'appointments#list', :as => 'appointments_list', :via => [:post, :options]
  match '/appointments/create' => 'appointments#create_appointment', :as => 'appointment_create', :via => [:post, :options]
  match '/appointments/pre_data' => 'appointments#pre_data', :as => 'appointments_pre_data', :via => [:get, :options]
  match '/appointments/:id/details' => 'appointments#details', :as => 'appointment_details', :via => [:get, :options]
  match '/appointments/update' => 'appointments#update_details', :as => 'appointment_update', :via => [:post, :options]

  match '/scheduler/save_new_jobs' => 'scheduler#save_new_jobs', :as => 'scheduler_save_new_jobs', :via => [:post, :options]
  match '/scheduler/fetch_data_to_allocate' => 'scheduler#fetch_data_to_allocate', :as => 'scheduler_fetch_data_to_allocate', :via => [:post, :options]
  match '/scheduler/fetch_data_for_date' => 'scheduler#fetch_data_for_date', :as => 'scheduler_fetch_data_for_date', :via => [:post, :options]
  match '/scheduler/fetch_driver_jobs' => 'scheduler#fetch_driver_jobs', :as => 'scheduler_fetch_driver_jobs', :via => [:post, :options]
  match '/scheduler/delete_job' => 'scheduler#delete_job', :as => 'scheduler_delete_job', :via => [:post, :options]

  match '/inspections/list' => 'inspections#list', :as => 'inspections_list', :via => [:post, :options]
  match '/inspections/download_inspection_pdf' => 'inspections#download_inspection_pdf', :as => 'download_inspection_pdf', :via => [:get, :options]
  match '/inspections/download_gemini_inspection_pdf' => 'inspections#download_gemini_inspection_pdf', :as => 'download_gemini_inspection_pdf', :via => [:get, :options], :defaults => {:format => 'pdf'}
  match '/inspections/download_clm_inspection_pdf' => 'inspections#download_clm_inspection_pdf', :as => 'download_clm_inspection_pdf', :via => [:get, :options], :defaults => {:format => 'pdf'}
  match '/inspections/:id' => 'inspections#details', :as => 'inspection_details', :via => [:get, :options]
  #auth module
      get  'auth/signin'
      post 'auth/signin'
      get  'auth/signout'
  
  resources :templates, only: [:show]
end

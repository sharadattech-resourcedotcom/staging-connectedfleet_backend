class Ability
  include CanCan::Ability

  def self.permission(controller, method)
    permissions = Hash.new

    #drivers controller
      permissions['drivers'] = Hash.new 
        permissions['drivers']['list'] = 'see drivers list'
        permissions['drivers']['details'] = 'see driver details'
        permissions['drivers']['getCurrentPeriod'] = 'see driver details'
        permissions['drivers']['getClosedPeriods'] = 'see driver details'
        permissions['drivers']['getLastPeriods'] = 'see driver details'
        permissions['drivers']['listTrips'] = 'see driver details'
        permissions['drivers']['listInspections'] = 'see driver inspections'
        permissions['drivers']['isLastClosedPeriod'] = 'see driver details'
        permissions['drivers']['fetchPeriod'] = 'see driver details'
        permissions['drivers']['create'] = 'create drivers'
        permissions['drivers']['update'] = 'update driver details'
        permissions['drivers']['changepassword'] = 'change driver password'
        permissions['drivers']['update'] = 'update driver details'
        permissions['drivers']['createPeriod'] = 'create period'
        permissions['drivers']['closePeriod'] = 'close period'
        permissions['drivers']['changePeriodStartMileage'] = 'change period start mileage'
        permissions['drivers']['approve_period'] = 'approve periods'
        permissions['drivers']['fetchPeriodsToApprove'] = 'approve periods'
        permissions['drivers']['reopenPeriod'] = 'reopen period'
        permissions['drivers']['approve'] = 'approve periods'
        permissions['drivers']['archive'] = 'archive users'

    #reports controller
      permissions['reports'] = Hash.new 
        permissions['reports']['list'] = 'see reports'
        permissions['reports']['generate'] = 'see reports'
        permissions['reports']['download_report_xls'] = 'see reports'

    #trips controller
      permissions['trips'] = Hash.new 
        permissions['trips']['list'] = 'see driver trips list'
        permissions['trips']['details'] = 'see trips details'
        permissions['trips']['listPoints'] = 'see points list'
        permissions['trips']['download_points_xls'] = 'see points list'
        permissions['trips']['updateTrip'] = 'update trips details'
        permissions['trips']['delete'] = 'delete trips'
        permissions['trips']['create'] = 'create trips'
        permissions['trips']['refreshPeriodMileage'] = 'refresh mileage'
        permissions['trips']['getLastPeriods'] = 'see driver trips list'
        permissions['trips']['moveToPeriod'] = 'move trip'

      permissions['dongle'] = Hash.new
        permissions['dongle']['trip'] = 'see points list'
        permissions['dongle']['chart_data'] = 'see points list'

      permissions['autoview'] = Hash.new
        permissions['autoview']['drivers'] = 'see autoview'

    #permissions controller
      permissions['management_panel'] = Hash.new
        permissions['management_panel']['fetch_permissions_data'] = 'grant permissions'
        permissions['management_panel']['fetch_roles_data'] = 'manage roles'     
        permissions['management_panel']['fetch_settings_data'] = 'see settings'
        permissions['management_panel']['fetch_create_user_data'] = 'create users'
        permissions['management_panel']['save_roles'] = 'manage roles' 
        permissions['management_panel']['new_role'] = 'manage roles' 
        permissions['management_panel']['save_user_permissions'] = 'grant permissions'
        permissions['management_panel']['create_user'] = 'create users'
        permissions['management_panel']['update_settings_data'] = 'see settings'
        permissions['management_panel']['remove_settings_value'] = 'see settings'
        permissions['management_panel']['fetch_logs'] = 'synchronize logs'
        permissions['management_panel']['synchronize_log'] = 'synchronize logs'
        permissions['management_panel']['fetch_managers_and_drivers'] = 'change driver manager'
        permissions['management_panel']['assign_manager_to_driver'] = 'change driver manager'
        permissions['management_panel']['vehicles_access_users'] = 'grant permissions'
        permissions['management_panel']['user_vehicles'] = 'grant permissions'
        permissions['management_panel']['save_user_vehicles'] = 'grant permissions'
        permissions['management_panel']['fetch_sales_staff'] = 'manage sales staff'
        permissions['management_panel']['save_sales_staff'] = 'manage sales staff'
        permissions['management_panel']['upload_apk'] = 'manage apps versions'

    permissions['hours_payroll'] = Hash.new
        permissions['hours_payroll']['fetch_drivers_types'] = 'manage drivers types'
        permissions['hours_payroll']['save_driver_type'] = 'manage drivers types'

      permissions['companies'] = Hash.new
        permissions['companies']['list'] = 'see companies list'
        permissions['companies']['create'] = 'see companies list'
        permissions['companies']['details'] = 'see companies list'
        permissions['companies']['getCompanyHeads'] = 'see companies list'
        permissions['companies']['getCompanyHead'] = 'see companies list'
        permissions['companies']['updateCompanyHead'] = 'see companies list'
        permissions['companies']['changeCompanyHeadPassword'] = 'see companies list'
        permissions['companies']['createCompanyHead'] = 'see companies list'
        permissions['companies']['updateDetails'] = 'edit companies'

     permissions['vehicles'] = Hash.new
        permissions['vehicles']['list'] = 'see vehicles list' 
        permissions['vehicles']['pre_data'] = 'see vehicles list'
        permissions['vehicles']['details'] = 'see vehicle details'
         permissions['vehicles']['vehicle_trips'] = 'see vehicle details'
        permissions['vehicles']['create_vehicle'] = 'create vehicles'   
        permissions['vehicles']['update_details'] = 'update vehicles'  

    permissions['appointments'] = Hash.new
        permissions['appointments']['list'] = 'see appointments list'
        permissions['appointments']['pre_data'] = 'see appointments list'   
        permissions['appointments']['details'] = 'see appointments list'  
        permissions['appointments']['create_appointment'] = 'create appointments'     
        permissions['appointments']['update_details'] = 'edit appointments'     

      permissions['scheduler'] = Hash.new
        permissions['scheduler']['save_new_jobs'] = 'manage scheduler'
        permissions['scheduler']['fetch_driver_jobs'] = 'see scheduler'
        permissions['scheduler']['fetch_data_to_allocate'] = 'manage scheduler'
        permissions['scheduler']['fetch_data_for_date'] = 'see scheduler'
        permissions['scheduler']['delete_job'] = 'manage scheduler'

    permissions['inspections'] = Hash.new
        permissions['inspections']['list'] = 'see inspections'
        permissions['inspections']['details'] = 'see inspection details'
        permissions['inspections']['download_inspection_pdf'] = 'see inspection details'
        permissions['inspections']['download_gemini_inspection_pdf'] = 'see inspection details'
        permissions['inspections']['download_clm_inspection_pdf'] = 'see inspection details'
        permissions['inspections']['download_estimator_inspection_pdf'] = 'see inspection details'


    return permissions[controller][method]
  end
end

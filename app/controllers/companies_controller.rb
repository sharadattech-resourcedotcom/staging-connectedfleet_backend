class CompaniesController < ApplicationController
  before_filter :authenticate_user

  def create
    c = Company.create(params[:company])
    return render :json => {:status => true, :errors => [], :data => {}}
  end

  def createCompanyHead
    #TODO: NEED AUTHORIZATION
    params[:companyHead][:on_trip] = false
    params[:companyHead][:user_type] = 4
    params[:companyHead][:role_id] = Role.where(:description => "Company Head").take.id
    u = User.create(params[:companyHead], params[:company][:id])
    return render :json => {:status => true, :errors => [], :data => {}}
  end

  def list
    if params[:filter] && params[:filter] != ''
      query_string = "%#{params[:filter]}%".downcase
      companies = Company.where("(id = ?) OR (lower(name) LIKE ?) OR (lower(address) LIKE ?) OR (lower(phone) LIKE ?)",
             params[:filter].to_i,
             query_string,
             query_string,
             query_string)
    else
      companies = Company.all
    end

    companies = companies.order('name asc')
    
    return render :json => {:status => true, :errors => [], :data => {:companies => companies}}
  end

  def details
    company = Company.where('id = ?', params[:id]).take
    #TODO: NEED AUTHORIZATION
    return render :json => {:status => true, :errors => [], :data => {:company => company}}
  end

  def updateDetails
    company = Company.where('id = ?', params[:company][:id]).take
    if company.update_attributes(company_params)
      return render :json => {:status => true, :errors => [], :data => {}}
    else
      return render :json => {:status => false, :errors => company.errors.full_messages, :data => {}}
    end
  end

  def getCompanyHeads
    users = User.where('company_id = ? AND role_id = ?', params[:company][:id], Role.where(:description => "Company Head").take.id)
    #TODO: NEED AUTHORIZATION
    return render :json => {:status => true, :errors => [], :data => {:users => users}}
  end

  def getCompanyHead
    user = User.where('id = ?', params[:id]).take
    #TODO: NEED AUTHORIZATION
    return render :json => {:status => true, :errors => [], :data => {:user => user}}
  end

  def updateCompanyHead
    #TODO: NEED AUTHORIZATIONz
    user = User.where('id = ?', params[:companyHead][:id]).take
    #TODO: NEED TO PUT IT INTO USER MODEL
    user.first_name = params[:companyHead][:first_name]
    user.last_name = params[:companyHead][:last_name]
    user.phone = params[:companyHead][:phone]
    user.email = params[:companyHead][:email]
    user.save
    return render :json => {:status => true, :errors => [], :data => {}}
  end
  def changeCompanyHeadPassword
    if params[:newpassword][:password]!= "" && params[:newpassword][:password] == params[:newpassword][:repeated]
      user = User.where('id = ?', params[:companyHead][:id]).take
      return render :json => user.change_password(params[:newpassword][:password],'',@session_user)
    end

    return render :json => {:status => false, :errors => ['New password and repeated password do not match'], :data => {}}
  end

  def company_params
    params.require(:company).permit(:name, :address, :phone, :enabled_inspections, :enabled_hours_payroll)
  end
  
end

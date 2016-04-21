class ReportsController < ApplicationController

	before_filter :authenticate_user
	
	def generate
		page_size = 100		
		@columns, @values, @users = Reports::Core.generate(@session_user, params[:report_name], params[:date_from], params[:date_to], params)
		@params = params
		#return render :json => {:status => true, :data => {:columns => @columns, :values => @values, :users => @users}}
		if !params[:page].nil?
	        if params[:page] == 0
	            count = @values.count
	            params[:page] = 1
	        else
	            count = nil
	        end
	        return render :json => {:status => true, :errors => [], :data => {:columns => @columns, :users => @users, :values => @values.slice!((params[:page].to_i - 1)*page_size,page_size), :count => count}}
	    else
	    	count = @values.count
	        return render :json => {:status => true, :errors => [], :data => {:columns => @columns, :users => @users, :values => @values, :count => count}}
	    end
	end

	def download_report_xls
		require 'spreadsheet'
		@columns, @values, @users = Reports::Core.generate(@session_user, params[:report_name], params[:date_from], params[:date_to], params)
		book = Spreadsheet::Workbook.new
			sheet = book.create_worksheet :name => 'Report '+ params[:report_name]

			@columns.each do |c|
      			sheet.row(0).push c
  			end
  			it = 1
  			@values.each do |v|
      			v.each do |val|
        			sheet.row(it).push val
      			end
      			it += 1
      		end
      		spreadsheet = StringIO.new
    		book.write spreadsheet
    		send_data spreadsheet.string, :filename => params[:report_name] + '_report_' + params[:date_from] + '_' + params[:date_to] + '.xls', :type =>  "application/vnd.ms-excel"

			return spreadsheet
	end

	def list
		render :json => Reports::Core.info_list(@session_user)
	end
end
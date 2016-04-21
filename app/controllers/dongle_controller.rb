class DongleController < ApplicationController
  	before_filter :authenticate_user

	def trip
  		trip = Trip.where('id = ?', params[:id]).take
    	user = User.where(users: {id:trip.user_id}).take

		points = Point.where('trip_id = ?', trip.id).order('timestamp asc')

		return render :json => {
			:points => points, 
			:stats => trip.trip_stat
		}
  	end

  	def chart_data
  		trip = Trip.where('trips.id = ?', params[:id]).eager_load(:trip_stat).take

  		return render :json => {
			:chart => (trip.trip_stat.nil?) ? nil : trip.trip_stat.chart_data(params)
		}
  	end
end
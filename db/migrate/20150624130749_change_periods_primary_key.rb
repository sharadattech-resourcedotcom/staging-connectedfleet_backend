class ChangePeriodsPrimaryKey < ActiveRecord::Migration

class Period < ActiveRecord::Base
  has_many :trips
  belongs_to :user, :class_name => 'User', :foreign_key => 'user_id'

    def self.assign_id_to_trips
     Trip.where("period_id IS ?",nil).each do |t|
      p = Period.where("user_id = ? AND start_date = ?", t.user_id, t.period_start_date).first
      t.update_attribute :period_id, p.period_id
     end
  	end
 end

 def change #Change PRIMARY KEY
 	Period.assign_id_to_trips
  	execute "ALTER TABLE trips DROP CONSTRAINT fk_trips_periods"
  	execute "ALTER TABLE periods DROP CONSTRAINT periods_pkey"
  	rename_column :periods, :period_id, :id 
  	execute "ALTER TABLE periods ADD PRIMARY KEY (id)"
  	execute "ALTER TABLE trips ADD CONSTRAINT fk_trips_periods FOREIGN KEY (period_id) REFERENCES periods(id)"
  	execute "UPDATE trips SET status = 'finished' WHERE status = 'closed'"
  end
end

class AddClosingTokenToPeriods < ActiveRecord::Migration
  def change
  	add_column :periods, :closing_token, :string
  	Period.where(:status => 'opened').each do |period|
  		period.closing_token = Digest::SHA1.hexdigest([Time.now, rand].join)
  		period.save
  	end
  end
end

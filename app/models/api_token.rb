class ApiToken < ActiveRecord::Base
	belongs_to :user

	def self.generate(user_id, ip_address)
		token = ApiToken.new
		token.access_token = Digest::SHA1.hexdigest([Time.now, rand].join)
		token.refresh_token = Digest::SHA1.hexdigest([Time.now, rand].join)
		token.user_id = user_id
		token.ip_address = ip_address
		token.expiration_date = Time.now + 2.hours
		token.save!

		return token
	end

	def as_json(options={})
      super(:only => [:access_token, :refresh_token, :expiration_date])
  end 

end

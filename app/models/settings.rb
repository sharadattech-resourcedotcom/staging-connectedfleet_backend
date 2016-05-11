class Settings < ActiveRecord::Base
	belongs_to :company

	def self.create(company_id)
	    set = Settings.new
	    set.company_id = company_id
	    set.red_line_value = 70
	    set.orange_line_value = 50
	    set.save
	    return set
    end

    def self.find_by_company_id(company_id)
    	if Settings.where(:company_id => company_id).exists?
            puts Settings.where(:company_id => company_id)
    		return Settings.where(:company_id => company_id)		
    	else
    		return Settings.create(company_id)
    	end
    end
end

class DriverType < ActiveRecord::Base
  belongs_to :company

  def self.create(company_id, name, hourly_rate, additional_hour_rate)
    t = DriverType.new
    t.company_id = company_id
    t.name = name
    t.hourly_rate = hourly_rate
    t.additional_hour_rate = additional_hour_rate
    t.save!
  end
end

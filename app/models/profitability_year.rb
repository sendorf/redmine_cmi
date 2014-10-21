class ProfitabilityYear < ActiveRecord::Base
  unloadable

  belongs_to :profitability_day

  def increase_data(field, value)
  	self[field] += value
    self.save
  end

  def self.create_year(day_id, year)
    ProfitabilityYear.new({:profitability_day_id => day_id, :year => year})
  end
end
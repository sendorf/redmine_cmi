class ProfitabilityDay < ActiveRecord::Base
  unloadable

  belongs_to :project
  has_many :profitability_years

  def increase_data(field, value, year = self.day.year)
  	self[field] += value

    profitability_year = self.get_year(year)
 	profitability_year.increase_data(field,value)

 	self.save
  end

  def get_year(year)
    logger.info "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
    logger.info self.inspect
    logger.info year.inspect
  	profitability_year = self.profitability_years.find(:first, 'year = ?', year)
  	if profitability_year.blank?
  		profitability_year = ProfitabilityYear.create_year(self.id, year)
  	end
    logger.info profitability_year.inspect
  	profitability_year
  end

  def day_before
    ProfitabilityDay.find(:first, :conditions => ["project_id = ? AND day < ?", self.project_id, self.day], :order => "day DESC")
  end

  def self.create_day(project_id, day)
    lastday = ProfitabilityDay.find(:first, :conditions => ["project_id = ? AND day < ?", project_id, day], :order => "day DESC")
    #lastday = ProfitabilityDay.find('project_id = ? AND day = ?',project_id,day-1.day)

    if lastday.present?
      lastday[:day] = Date.today
      ProfitabilityDay.create(lastday.attributes)
    else
      ProfitabilityDay.create({:project_id => project_id, :day => day})
    end
  end
end
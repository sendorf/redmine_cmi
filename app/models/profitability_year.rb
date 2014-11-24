class ProfitabilityYear < ActiveRecord::Base
  unloadable

  belongs_to :profitability_day

  def increase_data(field, value)
  	self[field] += value
    self.save
  end

  def self.create_year(day_id, year)
    #ProfitabilityYear.new({:profitability_day_id => day_id, :year => year})
=begin
    profitability_day = ProfitabilityDay.find(day_id)
    lastday = profitability_day.day_before
    #lastday = ProfitabilityDay.find('project_id = ? AND day = ?',project_id,day-1.day)

    if lastday.present?
      lastday_year = lastday.get_year(year)

      if lastday_year.present?
        lastday_year[:profitability_day_id] = day_id
        ProfitabilityYear.create(lastday_year.attributes)
      else
        ProfitabilityYear.create({:profitability_day_id => project_id, :year => year})
      end
    else
      ProfitabilityYear.create({:profitability_day_id => project_id, :year => year})
    end
=end

#=begin
    pday = ProfitabilityDay.find_by_id(day_id)
    #year_lastday = ProfitabilityYear.joins(:profitability_day).find(:first, :conditions => ["profitability_day.project_id = ? AND profitability_day <= ? AND year = ?", profitability_day.project_id, profitability_day.day, year], :order => "DESC profitability_day.day")
    #puts "#{pday}"
    #year_lastday = ProfitabilityYear.joins(:profitability_day).where("profitability_days.project_id = ? AND profitability_days.day < ? AND year = ?", pday.project_id, pday.day, year).order("'DESC profitability_days.day'").first
    year_lastday = last_year(pday.project_id, pday.day, year)

    if year_lastday.present?
      year_lastday[:profitability_day_id] = day_id
      ProfitabilityYear.create(year_lastday.attributes)
    else
      ProfitabilityYear.create({:profitability_day_id => day_id, :year => year})
    end
#=end

  end

  def self.last_year(project_id, day, year)
    ProfitabilityYear.joins(:profitability_day).where("profitability_days.project_id = ? AND profitability_days.day < ? AND year = ?", project_id, day, year).order("'DESC profitability_days.day'").first
  end
end
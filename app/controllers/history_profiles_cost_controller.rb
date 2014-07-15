class HistoryProfilesCostController < ApplicationController
  unloadable
=begin
  def edit
 #   params[:history_profiles_cost][:year] = params[:history_profiles_cost][:year].to_i
    data = params[:history_profiles_cost]
    hpc = HistoryProfilesCost.find_by_profile_and_year(data[:profile],data[:year])

    if hpc.blank?
      HistoryProfilesCost.new(data).save
    else
      hpc.update_attributes(data)
    end

    render :nothing => true
  end
=end

  def edit_year_costs
    year_profile_costs = JSON.parse params[:data]

    year_profile_costs.each do |data|
      profile_cost = HistoryProfilesCost.find_by_profile_and_year(data['profile'],data['year'])
      if profile_cost.value != data['value']
        profile_cost.edit(data['value'])
      end
    end

    render :nothing => true
  end

  def new_year_costs
    data = {year: params[:year]}

    params[:values].each do |k,v|
      data[:profile] = k
      if v.present?
        data[:value] = v
      else
        data[:value] = 0
      end
      HistoryProfilesCost.new(data).save
    end

    redirect_to '/admin/cost_history'
  end

  def delete_year_costs
    history_profiles_costs = HistoryProfilesCost.find(:all, :conditions => {:year => params[:year]})

    history_profiles_costs.each do |hpc|
      hpc.delete
    end

    redirect_to '/admin/cost_history'
  end
end

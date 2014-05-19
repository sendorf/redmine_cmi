class HistoryUserProfileController < ApplicationController
  unloadable
  def edit
    data = params[:history_user_profile]
    hup = HistoryUserProfile.find_by_id(data[:id])

    if params[:at_present] == "true"
      data[:finished_on]=nil
    end

    hup.update_attributes(data)

    render :nothing => true
  end
end

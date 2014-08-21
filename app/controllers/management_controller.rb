class ManagementController < ApplicationController
  unloadable

  include ManagementHelper
  before_filter :set_menu_item
  before_filter :authorize_global, :get_groups
  before_filter :get_roles, :only => :groups

  def status
    get_active_projects
    render :layout => !request.xhr?
  end

  def projects
    get_active_projects
    get_archived_projects
    render :layout => !request.xhr?
  end

  def groups
    group_metrics = CMI::GroupMetrics.new
    @metrics = group_metrics.metrics
    @total_cm = group_metrics.total_cm
    @total_deviation_percent = group_metrics.total_deviation_percent
  end

  def profitability
    service_custom_field_id = Setting.plugin_redmine_cmi['project_service_custom_field'];
    region_custom_field_id = Setting.plugin_redmine_cmi['project_region_custom_field'];
    @columns = ['name','bpo','cost','effort','income','mc','mc_percent']
    # @error = true if plugin is not config in admin menu
    @error = false

    if service_custom_field_id.blank? || region_custom_field_id.blank?
      @error = true
    else
      if params['columns'].present?
        @columns = params['columns']
      end

      @columns_data = get_profitability_columns(@columns)
      @projects = Project.get_active(params['service_filter'], params['region_filter'])
      @service_options = CustomField.find(service_custom_field_id).possible_values
      @region_options = CustomField.find(region_custom_field_id).possible_values
    end
  end

  private

  def set_menu_item
    self.class.menu_item params['action'].to_sym
  end

  def get_groups
    @groups = Project.groups
  end

  def get_roles
    @roles = User.roles
  end

  def get_active_projects
    if params[:selected_project_group].present?
      @projects = Project.active.all(:select => 'projects.*',
                                     :joins => :cmi_project_info,
                                     :conditions => ['cmi_project_infos.group = ?', params[:selected_project_group]],
                                     :order => :lft)
    else
      @projects = Project.active.all(:order => :lft)
    end
  end

  def get_archived_projects
    if params[:selected_project_group].present?
      @archived = Project.all(:select => 'projects.*',
                              :joins => :cmi_project_info,
                              :conditions => ["#{Project.table_name}.status = #{Project::STATUS_ARCHIVED} " +
                                              "AND cmi_project_infos.group = ?", params[:selected_project_group]],
                              :order => :lft)
    else
      @archived = Project.all(:conditions => ["#{Project.table_name}.status = #{Project::STATUS_ARCHIVED}"],
                              :order => :lft)
    end
  end
end

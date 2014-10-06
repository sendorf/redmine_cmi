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

  def summary
    service_custom_field_id = Setting.plugin_redmine_cmi['project_service_custom_field'];
    region_custom_field_id = Setting.plugin_redmine_cmi['project_region_custom_field'];

    service_options = CustomField.find(service_custom_field_id).possible_values
    region_options = CustomField.find(region_custom_field_id).possible_values

    @services = []
    service_options.each do |service|
      total_income = CustomValue.where('customized_type = ? AND custom_field_id = ? AND value = ?', "Project", service_custom_field_id, service).inject(0.0){ |sum, cv| sum + cv.customized.total_income}
      total_cost = CustomValue.where('customized_type = ? AND custom_field_id = ? AND value = ?', "Project", service_custom_field_id, service).inject(0.0){ |sum, cv| sum + cv.customized.total_cost}
      #@services[service] = (total_income-total_cost)/total_income
      if total_income!=0
        mc = (total_income-total_cost)/total_income
      else
        mc = 0
      end

      @services << [service, total_income-total_cost, mc]
    end
    @services_json = @services.to_json.html_safe

    @regions = []
    region_options.each do |region|
      total_income = CustomValue.where('customized_type = ? AND custom_field_id = ? AND value = ?', "Project", region_custom_field_id, region).inject(0.0){ |sum, cv| sum + cv.customized.total_income}
      total_cost = CustomValue.where('customized_type = ? AND custom_field_id = ? AND value = ?', "Project", region_custom_field_id, region).inject(0.0){ |sum, cv| sum + cv.customized.total_cost}
      #@regions[region] = (total_income-total_cost)/total_income
      if total_income!=0
        mc = (total_income-total_cost)/total_income
      else
        mc = 0
      end

      @regions << [region, total_income-total_cost, mc]
    end
    @regions_json = JSON.generate(@regions.as_json).html_safe
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

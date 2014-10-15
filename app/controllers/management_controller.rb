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
    # Obtenemos variables auxiliares
    service_custom_field_id = Setting.plugin_redmine_cmi['project_service_custom_field'];
    region_custom_field_id = Setting.plugin_redmine_cmi['project_region_custom_field'];
    project_manager_role_id = Setting.plugin_redmine_cpm['project_manager_role'];

    service_options = CustomField.find(service_custom_field_id).possible_values
    region_options = CustomField.find(region_custom_field_id).possible_values
    role_pm = Role.find_by_id(project_manager_role_id)

    # Calculamos rentabilidad por regiones, por servicios y por ambas
    @reg_serv = {}
    @regions = []
    @services = []
    services_aux = {}
    regions_aux = {}
    region_options.each do |region|
      @reg_serv[region] = {}
      service_options.each do |service|
        projects = Project.joins(
          "JOIN custom_values AS cv1 ON cv1.customized_id = projects.id AND cv1.customized_type = 'Project' 
          JOIN custom_values AS cv2 ON cv2.customized_id = projects.id AND cv2.customized_type = 'Project'").where(
          "cv1.custom_field_id=? AND cv1.value=? 
          AND cv2.custom_field_id=? AND cv2.value=?",
          service_custom_field_id,service,region_custom_field_id,region)

        total_income = projects.inject(0.0){ |sum, p| sum + p.total_income}
        total_cost = projects.inject(0.0){ |sum, p| sum + p.total_cost}

        # Acumulamos rentabilidad por región y servicio
        profit = total_income - total_cost
        if total_income!=0
          mc = profit/total_income
        else
          mc = 0
        end

        @reg_serv[region][service] = [profit, mc]
        # Acumulamos datos de rentabilidad por región
        if regions_aux[region].present?
          regions_aux[region] = [regions_aux[region][0]+total_income, regions_aux[region][1]+total_cost]
        else
          regions_aux[region] = [total_income, total_cost]
        end

        # Acumulamos datos de rentabilidad por servicio
        if services_aux[service].present?
          services_aux[service] = [services_aux[service][0]+total_income, services_aux[service][1]+total_cost]
        else
          services_aux[service] = [total_income, total_cost]
        end
      end
    end

#=begin
    # Calculamos rentabilidad por regiones
    regions_aux.each do |k,v|
      profit = v[0] - v[1]
      if v[0]!=0
        mc = profit/v[0]
      else
        mc = 0
      end
      @regions << [k, profit, mc]
    end

    # Calculamos rentabilidad por servicios
    services_aux.each do |k,v|
      profit = v[0] - v[1]
      if v[0]!=0
        mc = profit/v[0]
      else
        mc = 0
      end
      @services << [k, profit, mc]
    end

    @regions_json = JSON.generate(@regions.as_json).html_safe
    @services_json = JSON.generate(@services.as_json).html_safe
    @reg_serv_json = JSON.generate(@reg_serv.as_json).html_safe
#=end
    

=begin
    # Calculamos rentabilidad por servicios
    @services = []
    service_options.each do |service|
      total_income = CustomValue.where('customized_type = ? AND custom_field_id = ? AND value = ?', "Project", service_custom_field_id, service).inject(0.0){ |sum, cv| sum + cv.customized.total_income}
      #total_income = Project.joins(:custom_values).where('custom_values.custom_field_id = ? AND custom_values.value = ?',service_custom_field_id,service).inject(0.0){|sum, p| sum + p.total_income}
      total_cost = CustomValue.where('customized_type = ? AND custom_field_id = ? AND value = ?', "Project", service_custom_field_id, service).inject(0.0){ |sum, cv| sum + cv.customized.total_cost}

      if total_income!=0
        mc = (total_income-total_cost)/total_income
      else
        mc = 0
      end

      @services << [service, total_income-total_cost, mc]
    end
    @services_json = @services.to_json.html_safe

    # Calculamos rentabilidad por regiones
    @regions = []
    region_options.each do |region|
      total_income = CustomValue.where('customized_type = ? AND custom_field_id = ? AND value = ?', "Project", region_custom_field_id, region).inject(0.0){ |sum, cv| sum + cv.customized.total_income}
      total_cost = CustomValue.where('customized_type = ? AND custom_field_id = ? AND value = ?', "Project", region_custom_field_id, region).inject(0.0){ |sum, cv| sum + cv.customized.total_cost}

      if total_income!=0
        mc = (total_income-total_cost)/total_income
      else
        mc = 0
      end

      @regions << [region, total_income-total_cost, mc]
    end
    @regions_json = JSON.generate(@regions.as_json).html_safe
=end

    # Calculamos rentabilidad por jefes de proyecto
    projman_aux = {}
    Project.all.each do |p|
      project_manager = p.users_by_role[role_pm]
      if project_manager.present?
        total_income = p.total_income
        total_cost = p.total_cost
=begin        
        project_manager.each do |pm|
          if projman_aux[pm.id].present?
            projman_aux[pm.id] = [pm.login, projman_aux[pm.id][1]+total_income, projman_aux[pm.id][2]+total_cost]
          else
            projman_aux[pm.id] = [pm.login, total_income, total_cost]
          end
        end
=end
        key = project_manager.collect{|pm| pm.login}.sort
        if projman_aux[key].present?
          projman_aux[key] = [key.join(", "), projman_aux[key][1]+total_income, projman_aux[key][2]+total_cost]
        else
          projman_aux[key] = [key.join(", "), total_income, total_cost]
        end
      end
    end

    @projman = []
    #projman_aux.reject{|k,pm| k.length>3}.each do |k,pm|
    projman_aux.reject{|k,pm| k.length>3}.each do |k,pm|
      profit = pm[1]-pm[2]
      if pm[1]!=0
        mc = profit/pm[1]
      else
        mc = 0
      end
      @projman << [pm[0], profit, mc]
    end
    @projman_json = JSON.generate(@projman.as_json).html_safe
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

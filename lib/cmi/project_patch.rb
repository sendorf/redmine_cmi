require_dependency 'project'
require 'dispatcher' unless Rails::VERSION::MAJOR >= 3

module CMI
  module ProjectPatch
    def self.included(base) # :nodoc:
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)

      # Same as typing in the class
      base.class_eval do
        unloadable # Send unloadable so it will be reloaded in development

        has_one :cmi_project_info, :dependent => :destroy
        has_many :cmi_checkpoints, :dependent => :destroy
        has_many :profitability_days
      end
    end

    module ClassMethods
      def groups
        Setting.plugin_redmine_cmi['groups'].to_s.split(/[\n\r]+/) || []
      end

      def get_active(service, region)
        service_custom_field_id = Setting.plugin_redmine_cmi['project_service_custom_field'];
        region_custom_field_id = Setting.plugin_redmine_cmi['project_region_custom_field'];
        service_query = [];
        region_query = [];

        if service.blank? && region.blank?
          Project.includes(:time_entries).where("status != ? AND time_entries.tyear >= ?", 9, Time.zone.now.beginning_of_year)
        else
          if service.present?
            service_query = Project.includes(:custom_values, :time_entries).where("status != ? AND time_entries.tyear >= ? AND custom_values.custom_field_id = ? AND custom_values.value = ?", 9, Time.zone.now.beginning_of_year, service_custom_field_id, service)
          end

          if region.present?
            region_query = Project.includes(:custom_values, :time_entries).where("status != ? AND time_entries.tyear >= ? AND custom_values.custom_field_id = ? AND custom_values.value = ?", 9, Time.zone.now.beginning_of_year, region_custom_field_id, region)
          end

          if service_query.present? && region_query.present?
            service_query&region_query
          elsif service_query.present?
            service_query
          else
            region_query 
          end
        end
      end

      def get_normal_projects
        excluded_projects = (1..399).to_a #self.get_extra_projects + self.get_cross_projects
        Project.where('id NOT IN (?)', excluded_projects)
      end

      def get_extra_projects
        extra_projects_id = Setting.plugin_redmine_cmi['extra_projects'] || [0]
        Project.where('id IN (?)', extra_projects_id)
      end

      def get_cross_projects
        cross_projects_id = Setting.plugin_redmine_cmi['cross_projects'] || [0]
        Project.where('id IN (?)', cross_projects_id)
      end

      def global_summary
        normal_projects = get_normal_projects
        extra_projects = get_extra_projects
        cross_projects = get_cross_projects

        summary = {}
        summary['cross_income'] = ['Total ingresos horizontales', cross_projects.inject(0.0){ |sum, p| sum + p.scheduled_income}]
        summary['cross_expenditure'] = ['Total gastos horizontales', cross_projects.inject(0.0){ |sum, p| sum + p.scheduled_expenditure}]
        summary['extra_income'] = ['Total ingresos extraordinarios', extra_projects.inject(0.0){ |sum, p| sum + p.scheduled_income}]
        summary['extra_expenditure'] = ['Total gastos extraordinarios', extra_projects.inject(0.0){ |sum, p| sum + p.scheduled_expenditure}]
        summary['internal_expenditure'] = ['Total gastos internos', normal_projects.inject(0.0){ |sum, p| sum + p.scheduled_bpo + p.scheduled_effort}]
        summary['external_expenditure'] = ['Total gastos externos', normal_projects.inject(0.0){ |sum, p| sum + p.scheduled_external_cost}]
        summary['income'] = ['Total ingresos', normal_projects.inject(0.0){ |sum, p| sum + p.scheduled_income}]
        if summary['income'][1] != 0 
          summary['mc_percent'] = ['%MC', (summary['income'][1]-(summary['internal_expenditure'][1]+summary['external_expenditure'][1]))/summary['income'][1]]
          summary['mc'] = ['MC', summary['mc_percent'][1]*summary['income'][1]]
        else
          summary['mc_percent'] = ['%MC',0]
          summary['mc'] = ['MC',0]
        end 

        summary
      end
    end

    module InstanceMethods
      def last_checkpoint
        cmi_checkpoints.find(:first,
                             :order => 'checkpoint_date DESC')
      end

      def effort_done_by_role(role, to_date)
        cond = [ project_condition(Setting.display_subprojects_issues?) <<
                 ' AND (role = ?)' <<
                 ' AND (spent_on <= ?)',
                 role, to_date ]
        TimeEntry.sum(:hours,
                      :include => [:project],
                      :conditions => cond)
      end

      def first_checkpoint
        cmi_checkpoints.find(:first,
                             :order => 'checkpoint_date ASC')
      end

      def last_base_line(date=Date.today)
        base_line = cmi_checkpoints.find(:first,
                             :conditions => ['base_line = true AND checkpoint_date <= ?',date],
                             :order => 'checkpoint_date DESC')

        if !base_line
          base_line = first_checkpoint
        end

        base_line
      end

=begin      
      def total_bpo
        500
      end

      def total_effort
        #User.roles.inject(0.0) { |sum, role| sum + effort_done_by_role(role, Date.today) }
        750
      end

      def total_cost
        (5000+rand(2000)).to_f
        #2000.00
      end

      def total_income
        (10000+rand(5000)).to_f
        #10000.00
      end
=end
      def actual_mc
        #total_income-total_cost
        scheduled_income - scheduled_expenditure
      end

      def actual_mc_percent(decimals=nil)
        if scheduled_income != 0
          value = (actual_mc/scheduled_income)*100
        else
          value = 0.0
        end

        if decimals.present?
          value.round(decimals)
        else
          value
        end
      end
##########
      def incurred_bpo
        self.current_day.bpo_incurred
        #5000
      end

      def scheduled_bpo
        self.current_day.bpo_scheduled
        #10000
      end

      def incurred_external_cost
        self.current_day.external_cost_incurred
        #(5000+rand(5000)).to_f
      end

      def scheduled_external_cost
        self.current_day.external_cost_scheduled
        #(10000+rand(5000)).to_f
      end

      def incurred_income
        self.current_day.income_incurred
        #(20000+rand(10000)).to_f
      end

      def scheduled_income
        self.current_day.income_scheduled
        #(50000+rand(20000)).to_f
      end

      def incurred_effort
        self.current_day.effort_incurred
        #7500
      end

      def scheduled_effort
        self.current_day.effort_scheduled
        #15000
      end

      def incurred_expenditure
        self.incurred_bpo + self.incurred_external_cost + self.incurred_effort
      end

      def scheduled_expenditure
        self.scheduled_bpo + self.scheduled_external_cost + self.scheduled_effort
      end
##########
      def current_day
        #ProfitabilityDay.find_or_create_by_project_id_and_day(self.id, Date.today)
        logger.info "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
        profitability_day = self.profitability_days.find(:first, :conditions => ['day = ?', Date.today])
        logger.info profitability_day.inspect
        logger.info profitability_day.blank?.inspect

        if profitability_day.blank?
          profitability_day = ProfitabilityDay.create_day(self.id, Date.today)
        end
        profitability_day
      end
    end
  end
end
if Rails::VERSION::MAJOR >= 3
  ActionDispatch::Callbacks.to_prepare do
    # use require_dependency if you plan to utilize development mode
    Project.send(:include, CMI::ProjectPatch)
  end
else
  Dispatcher.to_prepare do
    Project.send(:include, CMI::ProjectPatch)
  end
end

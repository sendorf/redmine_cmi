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

      
      def total_bpo
        500
      end

      def total_effort
        #User.roles.inject(0.0) { |sum, role| sum + effort_done_by_role(role, Date.today) }
        750
      end

      def total_cost
        1000
      end

      def total_income
        5000
      end

      def actual_mc
        200
      end

      def actual_mc_percent
        "38%"
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

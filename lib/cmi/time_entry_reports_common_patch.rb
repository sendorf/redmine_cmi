require_dependency 'time_entry_reports_controller' if File.exists?("#{Rails.root}/app/controllers/time_entry_reports_controller.rb")
require_dependency 'timelog_controller' if File.exists?("#{Rails.root}/app/controllers/timelog_controller.rb")
require_dependency 'redmine/helpers/time_report' if File.exists?("#{Rails.root}/lib/redmine/helpers/time_report.rb")
require 'dispatcher' unless Rails::VERSION::MAJOR >= 3

# Patches Redmine's TimeEntryReportsController dinamically. Adds an option "Role" to the list of available criterias
# for the time entries report
module CMI
  module TimeEntryReportsCommonPatch
    def self.included(base) # :nodoc:
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)

      base.class_eval do
        unloadable # Send unloadable so it will be reloaded in development
        if File.exists?("#{Rails.root}/lib/redmine/helpers/time_report.rb")
          alias_method_chain :load_available_criteria, :profile
        else
          before_filter :load_profile_criteria, :only => [:report]
        end
      end
    end

    module ClassMethods
    end

    module InstanceMethods
      def load_profile_criteria
        @available_criteria['profile'] = {:sql => "Role",
                                           :label => :label_profile}
      end

      def load_available_criteria_with_profile
        @available_criteria = {}
        @available_criteria = load_available_criteria_without_profile
        @available_criteria['profile'] = {:sql => "#{TimeEntry.table_name}.role",
                                          :label => :label_profile}
        @available_criteria
      end
    end
  end
end

if Rails::VERSION::MAJOR >= 3
  ActionDispatch::Callbacks.to_prepare do
    TimeEntryReportsController.send(:include, CMI::TimeEntryReportsCommonPatch) if File.exists?("#{Rails.root}/app/controllers/time_entry_reports_controller.rb")
    # For Redmine >= 1.4
    Redmine::Helpers::TimeReport.send(:include, CMI::TimeEntryReportsCommonPatch) if File.exists?("#{Rails.root}/lib/redmine/helpers/time_report.rb")
  end
else
  Dispatcher.to_prepare do
    # For Redmine >= 1.1.0
    TimeEntryReportsController.send(:include, CMI::TimeEntryReportsCommonPatch) if File.exists?("#{Rails.root}/app/controllers/time_entry_reports_controller.rb")
    # For Redmine < 1.1.0
    TimelogController.send(:include, CMI::TimeEntryReportsCommonPatch) if File.exists?("#{Rails.root}/app/controllers/timelog_controller.rb")
    # For Redmine >= 1.4
    Redmine::Helpers::TimeReport.send(:include, CMI::TimeEntryReportsCommonPatch) if File.exists?("#{Rails.root}/lib/redmine/helpers/time_report.rb")
  end
end

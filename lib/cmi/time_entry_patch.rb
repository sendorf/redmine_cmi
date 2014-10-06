require_dependency 'time_entry'
require 'dispatcher' unless Rails::VERSION::MAJOR >= 3

# Patches Redmine's TimeEntry dinamically. Adds callbacks to save the role and
# cost added by the plugin.
module CMI
  module TimeEntryPatch
    def self.included(base) # :nodoc:
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)

      base.class_eval do
        unloadable # Send unloadable so it will be reloaded in development
        before_save :update_role_and_cost
        after_create :add_profitability_metrics
        after_update :update_profitability_metrics
        after_destroy :remove_profitability_metrics
      end
    end

    module ClassMethods
    end

    module InstanceMethods
      def update_role_and_cost
        self.role = self.user.role
        @hash_cost_actual_year = (HistoryProfilesCost.find :all).group_by(&:year)[self.tyear].group_by(&:profile)
        if attribute_present?("hours") and self.role.present?
          self.cost = (self.hours.to_f * @hash_cost_actual_year["#{self.role}"].first.value.to_f)
        end
      end

      def add_profitability_metrics
        self.project.cmi_project_info.total_effort += self.cost
        self.project.cmi_project_info.save
      end

      def update_profitability_metrics
        old_attributes = changed_attributes()

        if old_attributes['cost'].present?
          self.project.cmi_project_info.total_effort += self.cost - old_attributes['cost']
        end
        self.project.cmi_project_info.save
      end

      def remove_profitability_metrics
        self.project.cmi_project_info.total_effort -= self.cost
        self.project.cmi_project_info.save
      end
    end
  end
end

if Rails::VERSION::MAJOR >= 3
  ActionDispatch::Callbacks.to_prepare do
    # use require_dependency if you plan to utilize development mode
    TimeEntry.send(:include, CMI::TimeEntryPatch)
  end
else
  Dispatcher.to_prepare do
    TimeEntry.send(:include, CMI::TimeEntryPatch)
  end
end

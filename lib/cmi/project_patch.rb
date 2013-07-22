require_dependency 'project'
#require 'dispatcher'
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
        has_many :cmi_expenditures, :dependent => :destroy
      end
    end

    module ClassMethods
      def groups
        Setting.plugin_redmine_cmi['groups'].to_s.split(/[\n\r]+/) || []
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

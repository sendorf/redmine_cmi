# -*- coding: utf-8 -*-
Dir["#{File.dirname(__FILE__)}/config/initializers/**/*.rb"].sort.each do |initializer|
  Kernel.load(initializer)
end

require 'redmine'
require 'cmi/scoreboard_menu_helper_patch'
require 'cmi/time_entry_patch'
require 'cmi/time_entry_reports_common_patch'
require 'cmi/user_patch'
require 'cmi/users_helper_patch'
require 'cmi/project_patch'
require 'cmi/journal_patch'
require 'cmi/issue_bpo_dates_required_patch'
require 'cmi/settings_controller_patch'
require 'cmi/admin_controller_patch'


Redmine::Plugin.register :redmine_cmi do
  Rails.configuration.after_initialize do
    locale = if Setting.table_exists?
               Setting.default_language
             else
               'en'
             end
    I18n.with_locale(locale) do
      name I18n.t :'cmi.plugin_name'
      description I18n.t :'cmi.plugin_description'
      author 'Emergya Consultoría'
      version '0.9.4.1'
    end
  end

  settings :default => { }, :partial => 'settings/cmi_settings'

  requires_redmine :version_or_higher => '1.0.0'
  project_module :cmiplugin do
    permission :cmi_management, { :management => [:status, :projects, :groups] }

    permission :cmi_view_metrics, { :metrics => [:show, :recalculate] }
    permission :cmi_project_info, { :metrics => :info }

    permission :cmi_add_checkpoints, { :checkpoints => [:new, :create, :preview] }
    permission :cmi_edit_checkpoints, { :checkpoints => [:edit, :update, :preview, :new_journal] }
    permission :cmi_add_checkpoint_notes, { :checkpoints => [:edit, :update, :preview, :new_journal] }
    permission :cmi_edit_checkpoint_notes, { :checkpoints => [:preview, :edit_journal] }
    permission :cmi_edit_own_checkpoint_notes, { :checkpoints => [:preview, :edit_journal] }
    permission :cmi_view_checkpoints, { :checkpoints => [:index, :show] }
    permission :cmi_delete_checkpoints, { :checkpoints => :destroy }
  end

  menu :project_menu, :metrics, { :controller => 'metrics', :action => 'show' },
       :caption => :'cmi.caption_metrics',
       :after => :settings,
       :param => :project_id

  menu :top_menu, :cmi, { :controller => 'management', :action => 'projects'},
       :caption => 'CMI',
       :if => Proc.new { User.current.allowed_to?(:cmi_management, nil, :global => true) }

  menu :scoreboard_menu, :projects, { :controller => 'management', :action => 'projects' },
       :caption => :'cmi.caption_projects'

  menu :scoreboard_menu, :status, { :controller => 'management', :action => 'status' },
       :caption => :'cmi.caption_status'

  menu :scoreboard_menu, :groups, { :controller => 'management', :action => 'groups' },
       :caption => :'cmi.caption_groups'

  menu :admin_menu, :'cmi.label_cost_history', { :controller => 'admin', :action => 'cost_history' },
       :html => { :class => 'issue_statuses' },
       :caption => :'cmi.label_cost_history'
end

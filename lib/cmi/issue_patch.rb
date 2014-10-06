require 'dispatcher' unless Rails::VERSION::MAJOR >= 3

module CMI
  module IssuePatch
    def self.included(base)
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)

      base.class_eval do
        unloadable

        after_create :add_profitability_metrics
        after_update :update_profitability_metrics
        before_destroy :restore_deleted_issue_relations
        after_rollback :remove_profitability_metrics
        #acts_as_customizable
      end
    end

    module ClassMethods
      
    end

    module InstanceMethods
      def add_profitability_metrics
        self.save_custom_field_values

        bill_tracker_id = Setting.plugin_redmine_cmi['bill_tracker']
        provider_tracker_id = Setting.plugin_redmine_cmi['providers_tracker']

        case self.tracker_id.to_s
          when bill_tracker_id
            paid_statuses = Setting.plugin_redmine_cmi['bill_paid_statuses']
            amount_field_id = Setting.plugin_redmine_cmi['bill_amount_custom_field']
          when provider_tracker_id
            paid_statuses = Setting.plugin_redmine_cmi['providers_paid_statuses']
            amount_field_id = Setting.plugin_redmine_cmi['providers_tracker_custom_field']
          else
            return nil
        end

        if amount_field_id.present? && paid_statuses.present? && self.status_id.in?(paid_statuses.collect(&:to_i))
          case self.tracker_id.to_s
            when bill_tracker_id
              self.project.cmi_project_info.total_income += CustomValue.find_by_custom_field_id_and_customized_id(amount_field_id, self.id).value.to_f
            when provider_tracker_id
              self.project.cmi_project_info.total_cost += CustomValue.find_by_custom_field_id_and_customized_id(amount_field_id, self.id).value.to_f
            else
              return nil
          end

          self.project.cmi_project_info.save
        end
      end

      def update_profitability_metrics
        bill_tracker_id = Setting.plugin_redmine_cmi['bill_tracker']
        provider_tracker_id = Setting.plugin_redmine_cmi['providers_tracker']

        case self.tracker_id.to_s
          when bill_tracker_id
            paid_statuses = Setting.plugin_redmine_cmi['bill_paid_statuses']
            amount_field_id = Setting.plugin_redmine_cmi['bill_amount_custom_field']
          when provider_tracker_id
            paid_statuses = Setting.plugin_redmine_cmi['providers_paid_statuses']
            amount_field_id = Setting.plugin_redmine_cmi['providers_tracker_custom_field']
          else
            return nil
        end

        old_attributes = changed_attributes()

        if amount_field_id.present? && paid_statuses.present?
          old_status_id = old_attributes['status_id'] || self.status_id
          old_value = CustomValue.find_by_custom_field_id_and_customized_id(amount_field_id, self.id).value.to_f
          self.save_custom_field_values
          new_value = CustomValue.find_by_custom_field_id_and_customized_id(amount_field_id, self.id).value.to_f
          
          case self.tracker_id.to_s
            when bill_tracker_id
              if old_status_id.in?(paid_statuses.collect(&:to_i))
                self.project.cmi_project_info.total_income -= old_value
              end
              
              if self.status_id.in?(paid_statuses.collect(&:to_i))
                self.project.cmi_project_info.total_income += new_value
              end
            when provider_tracker_id
              if old_status_id.in?(paid_statuses.collect(&:to_i))
                self.project.cmi_project_info.total_cost -= old_value
              end

              if self.status_id.in?(paid_statuses.collect(&:to_i))
                self.project.cmi_project_info.total_cost += new_value
              end
            else
              return nil
          end

          self.project.cmi_project_info.save
        end
      end

      # Callback de control que se ejecuta la primera vez que se destruye la petición, para recuperar los custom_value eliminados
      def restore_deleted_issue_relations
        raise ActiveRecord::Rollback
      end


      def remove_profitability_metrics
        bill_tracker_id = Setting.plugin_redmine_cmi['bill_tracker']
        provider_tracker_id = Setting.plugin_redmine_cmi['providers_tracker']

        case self.tracker_id.to_s
          when bill_tracker_id
            paid_statuses = Setting.plugin_redmine_cmi['bill_paid_statuses']
            amount_field_id = Setting.plugin_redmine_cmi['bill_amount_custom_field']
          when provider_tracker_id
            paid_statuses = Setting.plugin_redmine_cmi['providers_paid_statuses']
            amount_field_id = Setting.plugin_redmine_cmi['providers_tracker_custom_field']
          else
            paid_statuses = nil
            amount_field_id = nil
        end

        if amount_field_id.present? && paid_statuses.present? && self.status_id.in?(paid_statuses.collect(&:to_i))
          case self.tracker_id.to_s
            when bill_tracker_id
              self.project.cmi_project_info.total_income -= CustomValue.find_by_custom_field_id_and_customized_id(amount_field_id, self.id).value.to_f
            when provider_tracker_id
              self.project.cmi_project_info.total_cost -= CustomValue.find_by_custom_field_id_and_customized_id(amount_field_id, self.id).value.to_f
          end

          self.project.cmi_project_info.save
        end

        # Vuelve a destruir la petición, ignorando el callback que llama al rollback y que interrumpe la eliminación
        Issue.skip_callback("destroy", :before, :restore_deleted_issue_relations)
        self.destroy
        Issue.set_callback("destroy", :before, :restore_deleted_issue_relations)
      end


    end
  end
end

if Rails::VERSION::MAJOR >= 3
  ActionDispatch::Callbacks.to_prepare do
    # use require_dependency if you plan to utilize development mode
    Issue.send(:include, CMI::IssuePatch)
  end
else
  Dispatcher.to_prepare do
    Issue.send(:include, CMI::IssuePatch)
  end
end

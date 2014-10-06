require_dependency 'custom_value'
require 'dispatcher' unless Rails::VERSION::MAJOR >= 3

module CMI
  module CustomValuePatch
    def self.included(base)
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)

      base.class_eval do
        unloadable
        #before_destroy :remove_profitability_metrics , :if => :is_profitability_value?
        #acts_as_customizable
      end
    end

    module ClassMethods
      
    end

    module InstanceMethods
      def is_profitability_value?
        logger.info "Voy a hacer la comprobación"
        logger.info self.inspect

        bill_tracker_id = Setting.plugin_redmine_cmi['bill_tracker']
        provider_tracker_id = Setting.plugin_redmine_cmi['providers_tracker']
        amount_field_id = Setting.plugin_redmine_cmi['bill_amount_custom_field']
        amount_field_id = Setting.plugin_redmine_cmi['providers_tracker_custom_field']
        paid_statuses = []
        amount_field_id = nil

        # Pertenece a un issue de tipo factura o proveedor
        if self.customized_type=='Issue'
          case self.customized.tracker_id.to_s
            when bill_tracker_id
              paid_statuses = Setting.plugin_redmine_cmi['bill_paid_statuses']
              amount_field_id = Setting.plugin_redmine_cmi['bill_amount_custom_field']
            when provider_tracker_id
              paid_statuses = Setting.plugin_redmine_cmi['providers_paid_statuses']
              amount_field_id = Setting.plugin_redmine_cmi['providers_tracker_custom_field']
            else
              logger.info "No he pasado la comprobación"
              return false
          end 

          # La issue estaba en estado pagado y pertenece a un custom_field que marca el valor que ha de usarse para las precargas de la rentabilidad
          if paid_statuses.include?(self.customized.status_id.to_s) && self.custom_field.id==amount_field_id
            return true
          end
        end
        logger.info "No he pasado la comprobación"
        return false
      end

      def remove_profitability_metrics
        logger.info "Voy a hacer la función de callback"
        bill_tracker_id = Setting.plugin_redmine_cmi['bill_tracker']
        provider_tracker_id = Setting.plugin_redmine_cmi['providers_tracker']

        case self.customized.tracker_id.to_s
          when bill_tracker_id
            self.customized.project.cmi_project_info.total_income -= self.value
          when provider_tracker_id
            self.customized.project.cmi_project_info.total_cost += self.value
        end

        self.customized.project.cmi_project_info.save
      end

    end

  end
end

if Rails::VERSION::MAJOR >= 3
  ActionDispatch::Callbacks.to_prepare do
    # use require_dependency if you plan to utilize development mode
    CustomValue.send(:include, CMI::CustomValuePatch)
  end
else
  Dispatcher.to_prepare do
    CustomValue.send(:include, CMI::CustomValuePatch)
  end
end

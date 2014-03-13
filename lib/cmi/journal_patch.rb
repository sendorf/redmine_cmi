#require_dependency 'journal'
require 'dispatcher' unless Rails::VERSION::MAJOR >= 3

module CMI
  module JournalPatch
    def self.included(base) # :nodoc:
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)

      # Same as typing in the class
      base.class_eval do
        unloadable # Send unloadable so it will be reloaded in development

        alias_method_chain :send_notification, :cmi
      end
    end

    module ClassMethods
    end

    module InstanceMethods
      def send_notification_with_cmi(journal)
        unless [ 'CmiCheckpoint' ].include? journal.journalized_type
          after_create_without_cmi(journal)
        end
      end
    end
  end
end

if Rails::VERSION::MAJOR >= 3
  ActionDispatch::Callbacks.to_prepare do
    Journal.send(:include, CMI::JournalPatch)
  end
else
  Dispatcher.to_prepare do
    Journal.send(:include, CMI::JournalPatch)
  end
end

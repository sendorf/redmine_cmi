require 'dispatcher' unless Rails::VERSION::MAJOR >= 3

module CMI
  module AdminControllerPatch
    def self.included(base) # :nodoc:
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)

      # Same as typing in the class
      base.class_eval do
        unloadable # Send unloadable so it will be reloaded in development
        helper :view
      end
    end

    module ClassMethods
    end

    module InstanceMethods
      def cost_history
        @roles = []
        costs = (HistoryProfilesCost.find :all)
        costs.each do |cost|
          @roles << cost.profile unless @roles.include?(cost.profile)
        end
        @year_costs = costs.group_by(&:year)
        @years = @year_costs.keys.sort.reverse

        @next_year = @years.first+1
      end 
    end
  end
end

if Rails::VERSION::MAJOR >= 3
  ActionDispatch::Callbacks.to_prepare do
    # use require_dependency if you plan to utilize development mode
    require_dependency 'admin_controller'
    AdminController.send(:include, CMI::AdminControllerPatch)
  end
else
  Dispatcher.to_prepare do
    require_dependency 'admin_controller'
    AdminController.send(:include, CMI::AdminControllerPatch)
  end
end
module CMI
  module Loaders
    module CreateData
      # Create needed custom fields
      def self.load
        UserCustomField.create(:type => "UserCustomField", :name => DEFAULT_VALUES['user_role_field'],
                               :field_format => "list", :possible_values => ['Project Manager', 'Functional Analyst', 'Analyst Developer', 'Senior Developer', 'Junior Developer', 'Scholarship', 'Observer'],
                               :regexp => "", :is_required => true, :is_for_all => false, :is_filter => false, :searchable => false, :editable => false, :default_value => nil)
      end
    end
  end
end

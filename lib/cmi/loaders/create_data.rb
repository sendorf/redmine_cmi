module CMI
  module Loaders
    module CreateData
      # Create needed custom fields
      def self.load
        UserCustomField.create(:type => "UserCustomField", :name => DEFAULT_VALUES['user_role_field'],
                               :field_format => "list", :possible_values => ['Project Manager', 'Functional Analyst', 'Analyst Developer', 'Senior Developer', 'Junior Developer', 'Scholarship', 'Observer'],
                               :regexp => "", :is_required => true, :is_for_all => false, :is_filter => false, :searchable => false, :editable => false, :default_value => nil)

        total_users = User.all.count
    
        ((total_users/500).to_i + 1).times do |iterator|
          users = User.limit(500).offset((iterator*500))
          users.each do |user|
            user.role = 'Observer'
          end
        end
      end
    end
  end
end

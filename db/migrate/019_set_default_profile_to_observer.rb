class SetDefaultProfileToObserver < ActiveRecord::Migration
  def up
    total_users = User.all.count
  	
  	((total_users/500).to_i + 1).times do |iterator|
      users = User.limit(500).offset((iterator*500))
      users.each do |user|
        user.role = 'Observer'
      end
    end
  end
end
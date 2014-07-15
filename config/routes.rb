RedmineApp::Application.routes.draw do
#Rails::application::routes.draw do |map|
  scope '/projects/:project_id/metrics' do
    resources :checkpoints, :controller => 'checkpoints' do
      member do
        post :new_journal
        post :edit_journal
        get  :edit_journal
      end
      collection do
        put :preview
      end
    end
  end

  scope '/projects/:project_id/metrics' do
    resources :expenditures, :controller => 'expenditures' do
      member do
        post :new_journal
        post :edit_journal
        get  :edit_journal
      end
      collection do
        put :preview
      end
    end
  end

resources :history_user_profile

#  resources :checkpoints,
#                :path_prefix => '/projects/:project_id/metrics',
#                :member => { :new_journal => :post, :edit_journal => [:get, :post] },
#                :collection => { :preview => :put }
#  resources :expenditures,
#                :path_prefix => '/projects/:project_id/metrics',
#                :member => { :new_journal => :post, :edit_journal => [:get, :post] },
#                :collection => { :preview => :put }
  match '/projects/:project_id/metrics/:action' => 'metrics', :as => :metrics
  match '/management/:action' => 'management', :as => :management
  match '/admin/cost_history' => 'admin#cost_history', :as => :cost_history
  match '/history_profiles_cost/:action' => 'history_profiles_cost'
  #match '/history_user_profile/:action' => 'history_user_profile'
  #match '/history_user_profile/edit/:id' => 'history_user_profile#edit'


#  map.metrics '/projects/:project_id/metrics/:action', :controller => 'metrics'
#  map.management '/management/:action', :controller => 'management'
#  map.cost_history '/admin/cost_history', :controller => 'admin', :action => 'cost_history'
  match '/settings/show_tracker_custom_fields' => 'settings#show_tracker_custom_fields'
end

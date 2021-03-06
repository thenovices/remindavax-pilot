RemindavaxPilot::Application.routes.draw do



  match '/prepare_reminders', :to => 'patients#prepare_reminders', :via => :get
  match '/send_reminders', :to => 'patients#send_reminders', :via => :post

  resources :patients do
    collection do
      get 'autocomplete'
      get 'today'
    end
    member do
      post 'check_in'
      resources :appointments
    end
  end
  resources :tb_patients do
    member do
      resources :treatments
    end
  end
  resources :users
  resources :sessions
  resources :phcs do
    resources :subcenters, :only => [:new, :create, :index]
    collection do
      get 'summary'
    end
  end
  resources :anms
  resources :ashas
  resources :subcenters, :only => [:show, :destroy]

  root :to => redirect('/patients/today')
  match '/login', :to => 'sessions#new'
  match '/logout', :to => 'sessions#destroy'
  match '/become_user', :to => 'sessions#become_user'
  match '/search', :to => 'patients#search'
  match '/search_tb', :to => 'tb_patients#search'

  post '/appointments/batch_update_dates'


  get '/cron/anm_sms'

  match '/summary', :to => 'phcs#summary'
  


  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end

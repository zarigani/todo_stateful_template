ActionController::Routing::Routes.draw do |map|
  map.root :controller => "todos", :action => "index"

  map.reset_email    '/reset_email/:code/:new_email', :controller => 'change_emails',    :action => 'show'
  # :codeでなく:idにしておくことで、editからupdateする時に、password_reset_codeが自然に送信される
  map.reset_password '/reset_password/:id',           :controller => 'forgot_passwords', :action => 'edit'
  map.activate       '/activate/:activation_code',    :controller => 'users',            :action => 'activate', :activation_code => nil
  map.logout   '/logout',   :controller => 'sessions', :action => 'destroy'
  map.login    '/login',    :controller => 'sessions', :action => 'new'
  map.register '/register', :controller => 'users',    :action => 'create'
  map.signup   '/signup',   :controller => 'users',    :action => 'new'

  map.resources :roles

  map.resources :users, :member => { :suspend => :put, :unsuspend => :put, :purge => :delete } do |users|
    users.resource  :change_password
    users.resource  :change_email
    users.resources :permissions
  end

  map.resource :forgot_password

  map.resource :session

  map.resources :todos

  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end

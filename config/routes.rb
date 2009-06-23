ActionController::Routing::Routes.draw do |map|
  map.resources :photos

  map.resources :groups

  map.resources :profiles

  map.resources :users, :has_one => [:password, :confirmation]
  map.resource :session
  map.resources :passwords
 
  map.root :controller => 'home'
  
  map.dashboard '/dashboard', :controller => 'users', :action => 'dashboard'
  
  #sessions
  map.login     '/login',     :controller => 'sessions',  :action => 'new'
  map.logout    '/logout',    :controller => 'sessions',  :action => 'destroy'
  map.signup    '/signup',    :controller => 'users',  :action => 'new'

end

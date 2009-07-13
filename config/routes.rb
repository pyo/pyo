ActionController::Routing::Routes.draw do |map|
  map.resources :ads

  map.resources :bookings, :as=>:events

  map.resources :tracks

  map.resources :activities

  map.resources :comments

  map.resources :alerts
  map.resources :photos
  map.resources :followings

  map.resources :groups,
                :member => {
                  :join => :put,
                  :leave => :put,
                  :approve => :put,
                  :deny => :put
                },
                :collection =>{
                  :request_group => :get,
                  :pending => :get
                }

  map.resources :profiles

  map.resources :users, 
                :has_one => [:password, :confirmation], 
                :member => {
                  :follow => :post,
                  :connects => :get,
                  :inbox => :get
                  } do |users|
                  users.resources :photos,
                                  :member => {:rate => :post}
                  users.resources :tracks,
                                  :member => {:rate => :post}
                  users.resources :direct_messages
                  users.resources :comments
                end
                
  map.resource  :session
  map.resources :passwords
 
  map.root :controller => 'home'
  
  map.dashboard '/dashboard', :controller => 'users', :action => 'dashboard'
  
  #sessions
  map.login     '/login',     :controller => 'sessions',  :action => 'new'
  map.logout    '/logout',    :controller => 'sessions',  :action => 'destroy'
  map.signup    '/signup',    :controller => 'users',  :action => 'new'
  map.music    '/music',    :controller => 'tracks',  :action => 'music'
  
  map.members '/members', :controller => 'users'

end

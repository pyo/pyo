ActionController::Routing::Routes.draw do |map|
  map.resources :group_categories

	
	map.resources :searches, :as=>"search", :only=>[:index]
  map.resources :videos, :member => {:status => :post, :status_update => :any, :upload => :get, :done => :get}
  map.resources :blogs
	map.resource :marketplace
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
                  :deny => :put,
                  :members => :get
                },
                :collection =>{
                  :request_group => :get,
                  :pending => :get
                }
	
	map.resources :groups, :as=>'categories'  do |group|
									group.resource :marketplace
								end

  map.resources :profiles

  map.resources :users, 
                :has_one => [:password, :confirmation], 
                :member => {
                  :follow => :post,
                  :connects => :get,
                  :inbox => :get,
									:change_admin_status => :put,
									:change_featured_status => :put
                  } do |users|
                  users.resources :photos,
                                  :member => {:rate => :post}
                  users.resources :tracks,
                                  :member => {:rate => :post}
									users.resources :videos, 
																	:member => {:rate => :post, :status => :post, :upload => :get, :done => :get}
                  users.resources :blogs,
                                  :member => {:rate => :post}
                  users.resources :direct_messages
                  users.resources :comments
									users.resources :bookings, :as=>:events,
																	:member => {:rate => :post}
									users.resources :ads,
																	:member => {:rate => :post}
                end
                
  map.resource  :session
  map.resources :passwords
 
  map.root :controller => 'home'
  
  map.dashboard '/dashboard', :controller => 'users', :action => 'dashboard'
  map.music '/music', :controller => 'tracks', :action => 'music'
  
  #sessions
  map.login     '/login',     :controller => 'sessions',  :action => 'new'
  map.logout    '/logout',    :controller => 'sessions',  :action => 'destroy'
  map.signup    '/signup',    :controller => 'users',  :action => 'new'
  map.music    '/music',    :controller => 'tracks',  :action => 'music'
  
  map.members '/members', :controller => 'users'
  
  map.redirect '/:id', :controller => "users", :action => 'show' # redirector

end

ActionController::Routing::Routes.draw do |map|
  map.connect '/about', :controller => 'home', :action => 'about'
  map.connect '/privacy_policy', :controller => 'home', :action => 'privacy_policy'
  map.settings '/settings', :controller => 'profiles', :action => 'edit'
  map.connects '/connects', :controller => 'users', :action => 'connects'
  map.resources :group_categories

	
	map.resources :searches, :as=>"search", :only=>[:index]
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

  map.resources :users, :as => "members",
                :has_one => [:password, :confirmation], 
                :member => {
                  :follow => :post,
                  :unfollow => :post,
                  :followers => :get,
                  :following => :get,
                  :likes => :get,
                  :updates => :get,
                  :connects => :get,
                  :inbox => :get,
									:change_admin_status => :put,
									:change_featured_status => :put
                  } do |users|
                  users.resources :photos,
                                  :member => {:rate => :post, :like => :post, :unlike => :post}
                  users.resources :tracks,
                                  :member => {:rate => :post, :like => :post, :unlike => :post}
									users.resources :videos, 
																	:member => {:rate => :post, :status => :post, :upload => :get, :done => :get, :like => :post, :unlike => :post}
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
  map.connect '/dashboard/:type', :controller => 'users', :action => 'dashboard'
  map.inbox '/inbox', :controller => 'users', :action => 'inbox'
  map.music '/music', :controller => 'tracks', :action => 'music'
  
  map.videos '/videos', :controller => 'videos', :action => 'videos', :conditions => { :method => :get }
  map.resources :videos, :member => {:status => :post, :status_update => :any, :upload => :get, :done => :get}
  
  
  #sessions
  map.login     '/login',     :controller => 'sessions',  :action => 'new'
  map.logout    '/logout',    :controller => 'sessions',  :action => 'destroy'
  map.signup    '/signup',    :controller => 'users',  :action => 'new'
  map.music    '/music',    :controller => 'tracks',  :action => 'music'
  
  map.redirect '/:id', :controller => "users", :action => 'show' # redirector

end

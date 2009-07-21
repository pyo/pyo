class MarketplacesController < ApplicationController
	
	before_filter :increment_tag_search_count
	
	def show
		
		@ads = ads.do_search(params)
		@events = bookings.do_search(params)
		
		@categories = Group.all
		
		@popular_tags =  Tag.current.most_popular.all :limit=>10
	end
	
	private
	
	def get_group
		Group.find_by_url(params[:group_id]) rescue nil
	end
	
	def ads
		group = get_group
		group ? group.ads : Ad
	end
	
	def bookings
		group = get_group
		group ? Group.find_by_url(params[:group_id]).bookings : Booking
	end
	
	protected
	def increment_tag_search_count
		Tag.up_mod_tags [params[:tags]].flatten 
	end
	
end
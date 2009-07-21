class MarketplacesController < ApplicationController
	
	def show
		
		@ads = ads.do_search(params)
		@events = bookings.do_search(params)
		
		@categories = Group.all
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
	
end
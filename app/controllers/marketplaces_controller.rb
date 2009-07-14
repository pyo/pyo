class MarketplacesController < ApplicationController
	
	def show
		@ads = ads.recent.all :limit=>4
		@events = bookings.recent.all :limit=>4
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
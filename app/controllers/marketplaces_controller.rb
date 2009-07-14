class MarketplacesController < ApplicationController
	
	def show
		@ads = Ad.recent.all :limit=>4
		@events = Booking.recent.all :limit=>4
	end
	
end
require 'test_helper'

class VideoTest < ActiveSupport::TestCase
  should_belong_to :user

	context "with many videos" do
		
		setup do
			10.times do
				factory = Factory.next(:video)
			end
		end
		
		should "have named scope recent " do
			ActiveRecord::Base.record_timestamps = false
			Video.all.each do |video|
				video.update_attribute(:created_at, (1..30).to_a.rand.days.ago)
			end
			ActiveRecord::Base.record_timestamps = true
			
			last_date = 10.years.since
			
			Video.recent.each do |video|
				assert video.created_at <= last_date
				last_date = video.created_at
			end
			
		end
		
	end
	
end

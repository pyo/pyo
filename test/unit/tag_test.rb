require 'test_helper'

class TagTest < ActiveSupport::TestCase
	
  # context "many tags" do
  #   
  #   setup do
  #     @tag_names = %w{cat hat mat pat}
  #     @tag_names.each{|tag| Tag.create(:name=>tag,:kind=>'tag')}
  #   end
  #   
  #   should "encrement Tags that are associated to and ad or event that has not expired" do
  #     Tag.up_mod_tags @tag_names
  #     Tag.all.each do |tag|
  #       assert tag.search_count == 1
  #     end
  #   end
  #   
  #   should "have named_scope for retrieving most_popular and least_popular tags" do
  #     i = 0
  #     Tag.all.each do |tag|
  #       i += 1
  #       tag.update_attribute :search_count, i
  #     end
  #     
  #     Tag.most_popular.each do |tag|
  #       assert tag.search_count == i
  #       i -= 1
  #     end
  #     
  #     Tag.least_popular.each do |tag|
  #       i += 1
  #       assert tag.search_count == i
  #     end
  #     
  #   end
  #   
  #   context "with ads and events" do
  #     
  #     setup do
  #       10.times do
  #         event = Factory.create(:booking)
  #         event.update_attribute :tag_list, Tag.all(:limit=>(1..5).to_a.rand, :order=>"RAND()").collect(&:name).join(",")
  #       end
  #     end
  #     
  #     # Tags#current only retrieves tags that belong to an Ad or Event that is not past its end date
  #     
  #     should "have a named scope for retrieving current tags" do
  #       first_tag = Tag.first
  #       Booking.all.select{|b|b.tags.include?(first_tag)}.each do |event|
  #         event.start_date -= 10.days
  #         event.end_date -= 10.days
  #         event.save
  #       end
  #       assert !Tag.current.include?(first_tag)
  #     end
  #     
  #     should "know if it is current" do
  #       first_tag = Tag.first
  #       Booking.all.select{|b|b.tags.include?(first_tag)}.each do |event|
  #         event.start_date -= 10.days
  #         event.end_date -= 10.days
  #         event.save
  #       end
  #       assert !first_tag.current?
  #     end
  #     
  #   end
  #   
  # end


end

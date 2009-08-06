require 'test_helper'

class BlogTest < ActiveSupport::TestCase
	
	context "many blogs" do
		
		setup do
				
			Blog.after_create.reject!{|c|c.method.to_s=="create_activity"}
			
			10.times do
				Factory.next(:blog)
			end
		end
		
		context "that belong to users" do
			
			setup do
				
				users = [Factory.next(:user),Factory.next(:user)]
				
				Blog.all.each_with_index do |blog,i|
					
					if i.odd?
						users.first.blogs << blog
					else
						users.last.blogs << blog
					end
					
				end
				
			end
			
			should "have named scope for retrieving super user blogs" do
				
				super_user = User.first
				super_user.update_attribute :super_user, true
				regular_user = User.last
				
				assert_equal Blog.super_user_posts.count, 5, "5 posts should belong to super user"
				
				Blog.super_user_posts.each do |blog|
					
					assert_equal blog.user, super_user
					
				end
				
				Blog.super_user_posts.each do |blog|
					
					assert_not_equal blog.user, regular_user
					
				end
				
			end
			
		end
		
	end
	
	
end

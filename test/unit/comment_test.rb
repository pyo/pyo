require 'test_helper'

class CommentTest < ActiveSupport::TestCase

  test "comment message should be greater than 255 characters" do
    @producer = Factory.create(:user)
    @comment = Comment.create(:producer => @producer, :message => "x" * 300)
    assert(@comment.message.size > 255, "Message was shortened event though it shouldn't be.")
  end

end

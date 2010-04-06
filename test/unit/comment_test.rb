require 'test_helper'

class CommentTest < ActiveSupport::TestCase

  test "comment message should allow more than 500 characters" do
    @producer = Factory.create(:user)
    @comment = Comment.create(:producer => @producer, :message => "x" * 503)
    assert(@comment.message.size > 500, "Message was smaller than 500")
  end

end

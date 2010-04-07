require 'test_helper'

class CommentTest < ActiveSupport::TestCase

  test "comment message should allow 300 characters" do
    @producer = Factory.create(:user)
    @comment = Comment.create(:producer => @producer, :message => "x" * 300)
    assert_makes_invalid(@comment) do
      @comment.message = "x" * 500
    end
  end

end

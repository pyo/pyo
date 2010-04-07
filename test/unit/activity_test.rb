require 'test_helper'

class ActivityTest < ActiveSupport::TestCase

  test "message should handle text greater than 255 chars" do
    @activity = Activity.create(:message => "x" * 300)
    assert(@activity.message.size > 255, "Mesage was truncated even though to is text field")
  end
  
  test "message should not allow more than 500 characetrs" do
    @activity = Activity.create(:message => "x" * 300)
    assert_makes_invalid(@activity) do
      @activity.message = "X" * 900
    end
    
  end

end

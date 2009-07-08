module UsersHelper
  def message_user_btn user
    button_to "message", new_user_direct_message_path(user), :method => :get
  end
end
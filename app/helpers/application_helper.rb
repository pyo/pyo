# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def is_owner? item
    (item.user == current_user)
  end
end

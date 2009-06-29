# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def is_owner? item
    case item
      when Comment
        (item.producer == current_user)
      else
      (item.user == current_user)
    end
  end
end

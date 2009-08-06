# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def is_owner? item
    # more like a duck?
    current_user == case true
      when item.respond_to?(:user) then item.user
      when item.respond_to?(:producer) then item.producer
    end
    # case item
    #   when Comment
    #     (item.producer == current_user)
    #   else
    #   (item.user == current_user)
    # end
  end
  
  def radio_for_rating val,checked
    attrs = {:class => "star"}
    attrs.merge(:disabled=>"disabled") unless current_user
    attrs.merge(:checked=>"true") if checked
    
    radio_button_tag("star1",val, checked,attrs)
  end
  
end

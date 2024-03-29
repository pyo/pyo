module GroupsHelper
  def leave_group_btn group, user
    html = capture do 
      form_for group, :url =>{ :action => "leave"} do |f|
        concat(hidden_field_tag("user_id", user.id))
        if current_user == user
          concat(f.submit("leave group"))
        else
          concat(f.submit("remove"))
        end
      end
    end
  end
  def join_group_btn group, user
    html = capture do 
      form_for group, :url =>{ :action => "join"} do |f|
        concat(hidden_field_tag("user_id", user.id))
        concat(f.submit("join"))
      end
    end
  end
  def join_or_leave_btn group, user
    if user
      unless user.groups.include? group
        join_group_btn(group,user)
      else
        leave_group_btn(group,user)
      end
    end
  end
  
  def approve_group_btn group
    html = capture do 
      form_for group, :url => approve_group_path(group) do |f|
        concat(hidden_field_tag("group_id", group.id))
        concat(f.submit("approve"))
      end
    end
  end
  
  def deny_group_btn group
    html = capture do 
      form_for group, :url => deny_group_path(group) do |f|
        concat(hidden_field_tag("group_id", group.id))
        concat(f.submit("deny"))
      end
    end
  end
  
end

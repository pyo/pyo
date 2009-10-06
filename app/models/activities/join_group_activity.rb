class JoinGroupActivity < Activity
  def to_json(options = {})
    {:id => id, :message => message, :user => producer.profile.username, :created_at => ActionView::Base.new.time_ago_in_words(created_at)}.to_json
  end
  
  def icon
    "icons/groups_16.png"
  end
end
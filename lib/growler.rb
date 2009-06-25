require 'ruby-growl'
class Growler
  def self.growl msg
    begin
      g = Growl.new "localhost", "ruby-growl",
                    ["ruby-growl Notification"]
      g.notify "ruby-growl Notification", ":::: From Rails ::::::::",
               "#{msg}",1,1
    rescue
      nil
    end
  end
end

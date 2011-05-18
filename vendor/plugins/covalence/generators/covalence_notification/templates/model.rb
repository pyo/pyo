class <%= class_name %> < ActiveRecord::Base
  include Covalence::Notification
<% attributes.select(&:reference?).each do |attribute| -%>
  belongs_to :<%= attribute.name %>
<% end -%>
end

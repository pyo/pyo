class <%= class_name %> < ActiveRecord::Base
  include Covalence::Membership
<% attributes.select(&:reference?).each do |attribute| -%>
  belongs_to :<%= attribute.name %>
<% end -%>
end

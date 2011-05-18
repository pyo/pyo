module Covalence
  
  module Member
    def self.included(model)
      model.extend(ClassMethods)
      model.class_eval do
        def self.covalence_options
          @covalence_options ||= {
            :membership_class => 'Membership',
            :conditions => nil
          }
        end
      end
    end
      
    module ClassMethods
      
      def is_member_of *groups
        covalence_options.merge!(groups.pop) if groups.last.is_a? Hash
        has_many :memberships, :as => :child, :class_name => covalence_options[:membership_class]
        groups.each do |group|
          has_many group, :through => :memberships, 
            :source => 'parent', 
            :source_type => group.to_s.classify, 
            :conditions => ['state is null or state != ?', 'pending']
        end
      end
    end 
    
    def set_role(group, role) 
      role = role.is_a?(String) ? role : role.to_s
      membership = self.memberships.find_by_parent_id_and_parent_type(group.id, group.class.name)
      membership.update_attribute(:status, role)
    end
    
    def role_in(group)
      membership = self.memberships.find_by_parent_id_and_parent_type(group.id, group.class.name)
      return membership ? membership.status : false
    end
    
    def member_in?(group)
      # if you don't know the !! is for, you probably shouldn't be here
      !!self.memberships.find_by_parent_id_and_parent_type(group.id, group.class.name)
    end
    
    def method_missing method, *args, &block
      if method.to_s =~ /^is_.*_of\?$/
        group = args[0]
        role = method.to_s.match(/^is_(.*)_of\?$/).captures[0].upcase.to_sym
        if group.has_role?(role)
          return self.role_in(group) && self.role_in(group).to_sym == role
        end
      elsif method.to_s =~ /^is_.*\?$/
        group = args[0]
        role = method.to_s.match(/^is_(.*)\?$/).captures[0].upcase.to_sym
        if group.has_role?(role)
          return self.role_in(group) && self.role_in(group).to_sym == role
        end
      elsif method.to_s =~ /^is_.*_of$/
        role = method.to_s.match(/^is_(.*)_of$/).captures[0].upcase.to_sym
        groups = []
        klass = args[0]
        klass.all.each do |group|
          if group.has_role?(role) && (self.role_in(group) && self.role_in(group).to_sym == role)
            groups << group
          end
        end
        return groups
      end
      super
    end
  end
end
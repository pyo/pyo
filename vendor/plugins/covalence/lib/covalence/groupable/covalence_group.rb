module Covalence

  module Group
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
      
      def has_group_assets(*assets)
        has_many :covalence_assets, :as => :groupable
        assets.each do |asset|
          has_many asset, :through => :covalence_assets, :source => :assetable, :source_type => asset.to_s.classify
          asset.to_s.classify.constantize.send(:has_many, :covalence_assets, :as => :assetable)
          asset.to_s.classify.constantize.send(:has_many, :groups, :through => :covalence_assets)
        end
      end
      
      def has_group_assets_through(klass, *assets)
        # TODO: refactor
        assets.each do |asset|
            define_method(asset) { 
              asset.to_s.classify.constantize.all(
                :joins => klass, 
                :conditions => [
                  "#{klass}_id in (select child_id from #{self.class.covalence_options[:membership_class].tableize} where parent_type = ? and parent_id = ? and child_type = ?)", 
                  self.class.name, 
                  self.id,
                  klass.to_s.classify
                ]
              )
            }  
        end
      end
      
      def has_members *members
        covalence_options.merge!(members.pop) if members.last.is_a? Hash
        table_name = covalence_options[:membership_class].tableize
        has_many :memberships, 
          :as => :parent, 
          :class_name => covalence_options[:membership_class], 
          :dependent => :destroy, 
          :conditions => covalence_options[:conditions]
          
        members.each do |member|
          has_many member, :through => :memberships, :source => 'child', :source_type => member.to_s.classify do
            
            def <<(*args)
              args.each do |arg|
                join(arg, nil)
              end
            end
            
            def remove(member)
              @owner.memberships.find_by_child_type_and_child_id(member.class.name, member.id).destroy
              @target.delete(member)
            end
                        
            def join(member, role = nil)
              if role != nil
                @owner.memberships.create(:child => member, :status => role.to_s)
              elsif @owner.class.respond_to?(:default_role)
                @owner.memberships.create(:child => member, :status => @owner.class.default_role.to_s)
              end
            end
           
          end
        end
      end
      
      def has_default_role(role)
        # TODO: does not work yet
        class << self
          attr_accessor :default_role
        end
        @default_role = role
      end
      
      def has_roles *roles
        class << self
          attr_accessor :roles
        end
        self.roles = roles
      end
    end
  
    def has_role?(role)
      self.class.roles.include?(role)
    end
    
    def members
      self.memberships.map(&:child)
    end
    
    def with_role(role)
      self.memberships.all(:conditions => ['status = ?', role.to_s]).map(&:child)
    end
  end
end
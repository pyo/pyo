require 'acts_as_flickr_user/acts_as_flickr_party'

module ActsAsFlickrUser
  class << self
    def included base
      base.extend ClassMethods
    end
  
    module ClassMethods
      def acts_as_flickr_user options = {}
        include ActsAsFlickrParty::User
        write_inheritable_attribute(:flickr_options, {
          :flickr_username => 'flickr_username',
          :flickr_nsid => 'flickr_nsid'
        }.merge(options))
        class_eval do
          before_save :set_nsid
        end
      end
      
      def flickr_options
        read_inheritable_attribute(:flickr_options)
      end
    end  
  end
end

if Object.const_defined?("ActiveRecord")
  ActiveRecord::Base.send(:include, ActsAsFlickrUser)
end
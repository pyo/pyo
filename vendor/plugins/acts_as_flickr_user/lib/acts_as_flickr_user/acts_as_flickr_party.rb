require 'httparty'

module ActsAsFlickrParty
 module API
   include HTTParty
   API_BASE = 'http://api.flickr.com/services/rest/'.freeze
   def self.call(method, args)
     post(API_BASE, :body => args.merge(:method => 'flickr.' + method, :api_key => configuration['api_key']))['rsp']
   end

   def self.configuration
     @configuration ||= YAML::load_file(File.join(RAILS_ROOT, 'config', 'flickr.yml'))[Rails.env]
   end
 end

 module Base58
   # for short url conversion
   CHARSET = "123456789abcdefghijkmnopqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ".freeze
   BASE = CHARSET.length.freeze

   def self.encode(value)
     value = value.to_i
     encoded = ''
     while(value >= BASE)
       mod = value % BASE
       encoded = CHARSET[mod,1] + encoded
       value = (value - mod)/BASE
     end
     CHARSET[value,1] + encoded
   end
 end

 module User
   def flickr_options
     @flickr_options ||= self.class.flickr_options
   end
   
   def flickr_url
     @flickr_url ||= self.send(flickr_options[:flickr_nsid]).present? ? "http://www.flickr.com/photos/" + self.send(flickr_options[:flickr_nsid]) : nil
   end
   
   def flickr_nsid(options = {})
     options = {:force => false}.merge(options)
     unless options[:force]
       @flickr_nsid ||= self.send(flickr_options[:flickr_nsid]) || API.call('people.findByUsername', :username => self.send(flickr_options[:flickr_username]))['user']['nsid']
     else
       @flick_nsid = API.call('people.findByUsername', :username => self.send(flickr_options[:flickr_username]))['user']['nsid']
     end
   rescue
     false
   end
      
   def flickr_photos(per_page = 10, scope = 'public')
     case scope
     when 'public' then API.call('people.getPublicPhotos', :user_id => flickr_nsid, :per_page => per_page)['photos']['photo'].map{ |hash| ActsAsFlickrParty::Photo.new(hash) }
     else []
     end
   end
   
   def set_nsid
     if self.send("#{flickr_options[:flickr_username]}_changed?")
       self.send("#{flickr_options[:flickr_nsid]}=", flickr_nsid(:force => true) || nil)
     end
     true
   end

 end

 class Photo
   attr_reader :ispublic, :farm, :title, :id, :server, :isfamily, :secret, :owner, :isfriend
   def initialize(hash)
     hash.each {|key, val| instance_variable_set "@#{key}", val }
   end
   
   def url(format = 'm')
     "http://farm#{farm}.static.flickr.com/#{server}/#{id}_#{secret}_#{format}.jpg"
   end

   def short_url
     "http://flic.kr/p/%s" % ActsAsFlickrParty::Base58.encode(id)
   end
 end
end
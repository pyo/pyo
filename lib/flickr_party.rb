require 'httparty'

module FlickrParty
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
    def self.nsid(username)
      API.call('people.findByUsername', :username => username)['user']['nsid']
    rescue
      false
    end

    def self.public_photos_from(username, per_page = 10)
      public_photos(nsid(username), per_page)
    end
    
    def self.public_photos(nsid, per_page = 10)
      API.call('people.getPublicPhotos', :user_id => nsid, :per_page => per_page)['photos']['photo']
    end
    
  end
  
  module Photo
    def self.url(photo, format = 'm')
      "http://farm#{photo['farm']}.static.flickr.com/#{photo['server']}/#{photo['id']}_#{photo['secret']}_#{format}.jpg"
    end
    
    def self.short_url(photo)
      "http://flic.kr/p/%s" % Base58.encode(photo['id'])
    end
  end
end

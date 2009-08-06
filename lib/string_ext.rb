module ActiveSupport
  module CoreExtensions
    module String
      module Inflections
        def capitalize_words
          self.gsub(/\b\w/) {|s| s.upcase}
        end
        
        def capitalize_words!
          self.gsub!(/\b\w/) {|s| s.upcase}
        end
      end
    end
  end
end

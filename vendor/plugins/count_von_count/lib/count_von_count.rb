# CountVonCount
require 'count_von_count/model'

module CountVonCount
  
  def self.debug=(debug)
    @debug = debug
  end
  
  def self.debug
    @debug ||= false
  end
  
  def self.blacklist=(list)
    @blacklist = list
  end
  
  def self.blacklist
    @blacklist ||= []
  end
  
  class View < ActiveRecord::Base
    set_table_name "count_von_count_views"
  end
end


if Object.const_defined?("ActiveRecord")
  ActiveRecord::Base.send(:include, CountVonCount::Model)
end
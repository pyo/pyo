#!/usr/local/bin/ruby

class SQS::Grant
  def self.atts
    [:email, :display_name, :id, :_permission]
  end

  self.atts.each do |att|
    attr_accessor att
  end
  
  def initialize( options={} )
    if options.is_a?( Hash )
      SQS::Grant.atts.each do |thing|
        self.send "#{thing}=", options[thing.to_s =~ /^_(.*)$/ ? $1.to_sym : thing]
      end
    else
      self.email = options
    end
  end

  def permission
    self._permission
  end

  def permission=( p )
    if SQS.permissions.has_key?( p.to_s.to_sym )
      self._permission = SQS.permissions[p.to_s.to_sym]
    else
      self._permission = p.to_s.upcase
    end
  end
end



#!/usr/local/bin/ruby

require 'uri'
require 'rexml/document'

class SQS::Queue
  private
  @@acceptable_schemes = ['https', 'http']

  public
  attr_accessor :url, :attributes
  def initialize( options={} )
    self.url = options.is_a?( Hash ) ? options[:url] : options
    bad_url = false
    self.attributes = {}
    begin
      u = URI.parse( self.url )
      bad_url = !@@acceptable_schemes.include?( u.scheme ) || u.host.to_s.empty? || u.path.to_s.empty?
    rescue URI::InvalidURIError, NoMethodError
      bad_url = true
    end
    raise URI::InvalidURIError, "'#{self.url}' does not seem to be a parseable URL. (Please provide all parts of the URL.)" if bad_url
  end

  def method_missing( symbol, *args )
    #method_missing intercepts .attribute and .attribute= calls
    method_name = symbol.to_s

    if method_name =~ /(.*)=$/
      attribute_name = $1.capitalize.gsub( /_([^_])/ ) { |m| $1.capitalize }.to_sym
      raise NoMethodError, "#{self.class.name}.#{method_name} takes one parameter" unless args.size == 1
      self.set_queue_attributes( attribute_name => args[0] )
    else
      attribute_name = method_name.capitalize.gsub( /_([^_])/ ) { |m| $1.capitalize }.to_sym
      self.get_queue_attributes( true ) if args[0] || @attributes.empty?
      raise NoMethodError, "This #{self.class.name} does not respond to #{method_name}" unless @attributes[attribute_name]
      @attributes[attribute_name]
    end
  end

  def ==( other_queue )
    self.url == other_queue.url
  rescue
    false
  end
  
  def to_s
    "#{self.class.to_s} '#{self.name}' (#{self.url})"
  end

  def delete( options=nil )
    force = options.is_a?( Hash ) && options[:force]
    doc = SQS.call_web_service( :Action => 'DeleteQueue', :ForceDeletion => force, :queue => self )
    true
  rescue Exception => e
    raise e
  end

  def delete!
    delete( :force => true )
  end
  def force_delete
    warn "Queue#force_delete is deprecated.  Please use Queue#delete!."
    delete!
  end


  def send_message( m )
    doc = SQS.call_web_service( :Action => 'SendMessage', :queue => self, :MessageBody => m.to_s )
    m = SQS::Message.new( :id => doc.message_id, :queue => self )
  rescue Exception => e
    raise e
  end

  def get_queue_attributes( force=false )
    if force || @attributes.empty?
      params = { :Action => 'GetQueueAttributes', :queue => self, :Attribute => 'All' }
      doc = SQS.call_web_service( params )

      doc.attributed_values.each do |v|
        @attributes[ v.attribute.to_sym ] = (v.value == v.value.to_i.to_s ? v.value.to_i : v.value )
      end
    end
    true
  rescue Exception => e
    raise e
  end

  def set_queue_attributes( atts={} )
    @attributes = {} unless @attributes
    params = { :Action => 'SetQueueAttributes', :queue => self.url }
    atts.each do |k,v|
      params[:Attribute] = k
      params[:Value] = v
      doc = SQS.call_web_service( params )
      @attributes[k] = v
    end
    true
  rescue Exception => e
    raise e
  end

  def empty?
    self.peek_message.nil?
  end


  def peek_message
    # returns the first element of what peek_messages returns
    m = self.peek_messages( :count => 1 ).first
    yield( m ) if block_given?
    m
  end
  def peek_messages( options={} )
    # returns an array of SQS::Message instances (could be empty)
    receive_messages( options.merge( :message_ttl => 0 ) )
  end

  def receive_message
    # returns the first element of what receive_messages returns
    m = self.receive_messages( :count => 1 ).first
    yield( m ) if block_given?
    m
  end
  def receive_messages( options={} )
    # returns an array of SQS::Message instances (could be empty)
    count = options.has_key?( :count ) ? options[:count].to_i : 1
    params = { :Action => 'ReceiveMessage', :queue => self, :NumberOfMessages => count }
    params[:VisibilityTimeout] = options[:message_ttl] if options.has_key?( :message_ttl )
    doc = SQS.call_web_service( params )

    messages = Array.new
    doc.messages.each do |m|
      messages << SQS::Message.new( :id => m.message_id, :queue => self, :body => m.message_body)
    end
    messages
  rescue Exception => e
    raise e
  end



  def add_grant( options={} )
    doc = SQS.call_web_service(
      :Action => 'AddGrant',
      :queue => self,
      :Permission => SQS.permissions[options[:permission]],
      'Grantee.EmailAddress'.to_sym => options[:email].respond_to?( :email ) ? options[:email].email : options[:email]
    )
    true
  rescue Exception => e
    raise e
  end

  def remove_grant( options={} )
    params = {
      :Action => 'RemoveGrant',
      :queue => self,
      :Permission => SQS.permissions( options[:permission] ),
    }

    if !options[:id].nil?
      params['Grantee.ID'.to_sym] = options[:id].respond_to?( :id ) && !options[:id].is_a?( String ) ? options[:id].id : options[:id]
    elsif !options[:email].nil?
      params['Grantee.EmailAddress'.to_sym] = options[:email].respond_to?( :email ) ? options[:email].email : options[:email]
    else
      raise ArgumentError, "You must specify either a grant id (:id) or a grantee email address (:email) when calling remove_grant."
    end

    doc = SQS.call_web_service( params )
    true
  rescue Exception => e
    raise e
  end

  def list_grants( p=nil )
    params = { :Action => 'ListGrants', :queue => self }

    case p
    when SQS::Grant
      if p.email.to_s.empty?
        params['Grantee.ID'.to_sym] = p.id
      else
        params['Grantee.EmailAddress'.to_sym] = p.email
      end
    when Hash
      params['Grantee.EmailAddress'.to_sym] = p[:email] unless p[:email].to_s.empty?
      params['Grantee.ID'.to_sym] = p[:id] unless p[:id].to_s.empty?
      params[:Permission] = SQS.permissions[p[:permission]] unless p[:permission].to_s.empty?
    end
      
    
    doc = SQS.call_web_service( params )
    grants = Array.new
    doc.grant_lists.each do |list|
      list.grantees.each do |g|
        grants << SQS::Grant.new( :id => g.id( :grantee ), :display_name => g.display_name, :permission => list.permission )
      end
    end
    grants
  rescue Exception => e
    raise e
  end

  def each_grant( &block )
    self.list_grants.each do |g|
      block.call( g )
    end
  end

  def each_message( &block )
    # This is an infinite loop.
    # You must either break out of it
    # Or delete each message!
    while m = self.peek_message
      block.call( m )
    end
  end

  def name
    # return everything after the last slash
    self.url =~ /([^\/]*)$/ ? $1 : ''
  end

  def self.default_visibility_timeout
    30
  end

  def exist?
    SQS.get_queue( self.name )
    true
  rescue
    false
  end
  alias_method :exists?, :exist?
end

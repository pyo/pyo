#!/usr/local/bin/ruby

dir = File::dirname( __FILE__ )

#require "#{dir}/aws"
require 'base64'
require 'erb'
require 'net/http'
require 'openssl'
require 'rexml/document'
require 'yaml'
#include Digest
include ERB::Util

class SQS

  dir = File.dirname( __FILE__ )
  require "#{dir}/sqs/queue"
  require "#{dir}/sqs/message"
  require "#{dir}/sqs/grant"
  
  
  def self.new
    # rather than a singleton class, never allow instantiation
    return SQS
  end
  
  def self.prepare_parameters_for_signing( hsh={} )
    # Param-name1Param-value1Param-name2Param-value2...Param-nameNParam-valueN
    # see http://docs.amazonwebservices.com/AWSSimpleQueueService/2006-04-01/Query/QueryAuth.html
    hsh.keys.sort{ |a,b| a.to_s.casecmp( b.to_s ) }.map{ |a| "#{a.to_s}#{hsh[a].to_s}"}.join( '' )
  end

  def self.prepare_parameters_for_query( hsh={} )
    # Param-name1Param-value1Param-name2Param-value2...Param-nameNParam-valueN
    # see http://docs.amazonwebservices.com/AWSSimpleQueueService/2006-04-01/Query/QueryAuth.html
    hsh.keys.map{ |a| "#{url_encode( a.to_s )}=#{url_encode( hsh[a].to_s )}"}.join( '&' )
  end

  def self.access_key_id=( i )
    @@access_key_id = i
  end
  def self.access_key_id
    @@access_key_id
  end
  def self.secret_access_key=( k )
    @@secret_access_key = k
  end
  def self.secret_access_key
    @@secret_access_key
  end

  # Expects YAML
  def self.conf_file=( path )
    @@conf_file = File.expand_path( path )
    settings = YAML.load_file( @@conf_file  )
    %w{ access_key_id secret_access_key }.each do |attr|
      self.send( "#{attr}=", settings[attr] )
    end
  rescue
    # Warn, but continue operation
    warn "\n\nWARNING:\n#{$!.message}\n(Check #{caller[0]})"
  end
  
  def self.conf_file
    @@conf_file
  end
  
  def self.url_for_auery=( u )
    @@url_for_query = u
  end
  def self.url_for_query
    @@url_for_query
  end

  def self.create_signature( params )
    prepared_parameters = self.prepare_parameters_for_signing( params )
    digest = OpenSSL::HMAC::digest( OpenSSL::Digest::Digest.new("SHA1"), self.secret_access_key, prepared_parameters )
    b64_hmac = Base64.encode64( digest ).strip
    b64_hmac
  end

  def self.permissions( perm=nil )
    perms = { :full => 'FULLCONTROL', :send => 'SENDMESSAGE', :receive => 'RECEIVEMESSAGE' }
    if perm.nil?
      perms
    else
      perms.has_value?( perm.to_s.upcase ) ? perm.to_s.upcase : perms[perm.to_sym]
    end
  end

  def self.create_queue( params={} )
    params = params.is_a?( Hash ) ? params : { :name => params }
    params[:Action] = 'CreateQueue'
    return false if params[:name].to_s.empty?
    params[:QueueName] = params[:name]
    params.delete( :name )

    doc = self.call_web_service( params )
    queue_url = doc.queue_url
    SQS::Queue.new( :url => queue_url )

  rescue Exception => e
    raise e
  end



  def self.get_queue( params={} )
    params = params.is_a?( Hash ) ? params : { :name => params }
    self.list_queues( :prefix => params[:name] ).each do |queue|
      return queue if queue.name == params[:name]
    end

    raise SQS::UnavailableQueue, "Could not find the queue named '#{params[:name]}'"
  rescue Exception => e
    raise e
  end


  def self.list_queues( params={} )
    # use :prefix => 'Boo' to get queues whose names begin with 'Boo'
    params = params.is_a?( Hash ) ? params : { }
    params[:Action] = 'ListQueues'
    if ( params.has_key?( :prefix ) )
      params[:QueueNamePrefix] = params[:prefix]
      params.delete( :prefix )
    end

    doc = self.call_web_service( params )
    queues = Array.new()

    begin
      REXML::XPath.each( doc, '/ListQueuesResponse/QueueUrl' ) do |element|
        queues << SQS::Queue.new( :url => element.text )
      end
    rescue RuntimeError => e
      queues = Array.new()
    end
    queues
  rescue Exception => e
    raise e
  end

  def self.each_queue( params={}, &block )
    self.list_queues( params ).each do |q|
      block.call( q )
    end
  rescue Exception => e
    raise e
  end



  def self.api_version
    '2007-05-01'
  end

  def self.signature_version
    1
  end

  def self.request_ttl
    30
  end

  def self.retry_attempts
    @@retry_attempts
  end
  def self.retry_attempts=( new_value )
    @@retry_attempts = new_value.to_i
  rescue NoMethodError
    raise ArgumentError.new( $!.message )
  end

  def self.params_for_query( t=nil )
    expires = t.is_a?( Time ) ? t : Time.now.request_expires
    
    {
      :DefaultVisibilityTimeout => SQS::Queue.default_visibility_timeout,
      :Version => self.api_version,
      :AWSAccessKeyId => self.access_key_id,
      :SignatureVersion => self.signature_version,
      :Expires => expires.to_iso8601
    }
  end
  
  def self.counter
    @@counter
  end
  def self.reset_counter
    @@counter = 0
  end
  def self.increment_counter
    @@counter += 1
  end

  def self.reasons_to_retry
    @@reasons_to_retry.dup
  end
  def self.add_reasons_to_retry( *string_or_array )
    @@reasons_to_retry += (
                            string_or_array[0].is_a?( String ) ?
                            string_or_array :
                            string_or_array[0]
                          )
    @@reasons_to_retry.uniq!
  rescue TypeError
    raise ArgumentError.new( $!.message )
  end
  
  def self.remove_reasons_to_retry( *string_or_array )
    @@reasons_to_retry -= (
                            string_or_array[0].is_a?( String ) ?
                            string_or_array :
                            string_or_array[0]
                          )
  rescue TypeError
    raise ArgumentError.new( $!.message )
  end
  class <<self
    alias :add_reason_to_retry :add_reasons_to_retry
    alias :remove_reason_to_retry :remove_reasons_to_retry
  end

  protected
  @@retry_attempts = 10;
  @@counter = 0;
  @@conf_file = ''
  @@secret_access_key = 'Replace this with your secret access key'
  @@access_key_id = 'Replace this with your access key id'
  @@url_for_query = 'http://queue.amazonaws.com/'
  @@exception_classes = {}
  @@reasons_to_retry = [ 'ServiceUnavailable' ]

  def self.get_exception_class( s=nil )
    raise ArgumentError, "Please specify an error code" if s.to_s.empty?
    class_name = s.to_s.gsub( /[^a-z0-9]/i, '' )
    class_name = "#{$1.capitalize}#{$2}" if class_name =~ /^(.)(.*)/
    class_name = class_name.to_sym
    @@exception_classes[class_name] ||= eval( "class #{class_name.to_s} < RuntimeError ; end ; #{class_name.to_s}" , binding, __FILE__, __LINE__ )
  end

  def self.get_exception( params=nil )
    raise ArgumentError, "You must pass a Hash to SQS.get_exception" unless params.is_a?( Hash )

    if params[:document].respond_to?( :error_code ) && params[:document].respond_to?( :error_message )
      doc = params[:document]
      error_code = params[:document].error_code
      error_message = params[:document].error_message
    else
      raise ArgumentError, "Cannot determine error code and message"
    end
    if params[:url].respond_to?( :to_s )
      url = params[:url].to_s
    else
      raise ArgumentError, "Cannot determine url"
    end
    attempts = params[:attempts].respond_to?( :to_i ) ? attempts = params[:attempts].to_i : 0

    self.get_exception_class( error_code ).new( "#{error_message} #{attempts > 0 ? "(After #{attempts} attempt#{attempts == 1 ? '' : 's'}) " : ''}(The XML returned from #{url} was #{doc})" )
  end

  def self.call_web_service( params )
    params = self.params_for_query.merge( params )

    begin
      retries = params[:retries] + 0
      params.delete( :retries )
      retries = 1 if retries < 1
    rescue
      retries = self.retry_attempts
    end


    if !params[:queue].nil?
      if params[:queue].respond_to?( :url )
        url = params[:queue].url
      else
        url = params[:queue].to_s
      end
      params.delete( :queue )
    else
      url = "#{self.url_for_query}"
    end
    
    remaining_attempts = retries + 1
    while remaining_attempts > 0
      url_to_use = url + "?#{self.prepare_parameters_for_query( params )}&Signature="

      url_encoded_signature = url_encode( self.create_signature( params ) )

      begin
        response = Net::HTTP.get( URI.parse( url_to_use + url_encoded_signature ) )
        self.increment_counter
        doc = REXML::Document.new( response )
      rescue
        raise $!
      end

      remaining_attempts -= 1

      break if remaining_attempts == 0 || !self.reasons_to_retry.include?( doc.error_code.to_s )

      sleep( rand( 500 ) / 1000.0 ) #sleep for up to half a second
    end
      
    raise self.get_exception(
      :document => doc,
      :url => ( url_to_use + url_encoded_signature ),
      :attempts => ( retries + 1 - remaining_attempts )
    ) unless doc.status == 'Success'

    doc
  rescue Exception => e
    if e.is_a?( SocketError )
      raise SocketError, "Do you have internet access? (#{e.message})"
    else
      raise e
    end
  end
end

class Time
  def to_iso8601
    self.utc.strftime( "%Y-%m-%dT%H:%M:%SZ" ) 
  end

  def request_expires
    self + SQS.request_ttl
  end
end

module REXML
  class Document
  
    def error_code ; self.node_text( '/Response/Errors/Error/Code' ) ; end
    def error_message ; self.node_text( '/Response/Errors/Error/Message' ) ; end
    def request_id ; self.node_text( '*/ResponseStatus/RequestId' ) ; end

    def queue_url ; self.node_text( '/CreateQueueResponse/QueueUrl' ) ; end
    def status ; self.node_text( '*/ResponseStatus/StatusCode' ) ; end

    def message_id( type=:send ) ; self.node_text( "/#{type.to_s.capitalize}MessageResponse/#{ type == :send ? '' : 'Message/'}MessageId" ) ; end
    def message_body( type=:peek ) ; self.node_text( "/#{type.to_s.capitalize}MessageResponse/Message/MessageBody" ) ; end

    def messages( type=:receive ) ; self.nodes( "/#{type.to_s.capitalize}MessageResponse#{ type == :send ? '' : '/Message'}" ) ; end
    def attributed_values( type=:get ) ; self.nodes( "/#{type.to_s.capitalize}QueueAttributesResponse#{ type == :send ? '' : '/AttributedValue'}" ) ; end

    def visibility_timeout( type=:get ) ; self.node_text( "/#{type.to_s.capitalize}VisibilityTimeoutResponse/VisibilityTimeout" ).to_i ; end

    def grant_lists( type=:list ) ; self.nodes("/#{type.to_s.capitalize}GrantsResponse#{ type == :send ? '' : '/GrantList'}" ) ; end

    protected
    def node_text( xpath )
      code = REXML::XPath.first( self, xpath )
      code.to_s.empty? ? '' : code.text
    rescue
#      puts "XPath #{xpath} on #{self.to_s} resulted in #{$!.class.name}"
      raise $!
    end
    
    def nodes( xpath )
      REXML::XPath.match( self, xpath )
    end
  end


  class Element
    def message_id ; self.node_text( "MessageId" ) ; end
    def message_body ; self.node_text( "MessageBody" ) ; end

    def attribute ; self.node_text( "Attribute" ) ; end
    def value ; self.node_text( "Value" ) ; end

    def id( type=:message ) ; self.node_text( type == :grantee ? "ID" : "Id" ) ; end
    def display_name ; self.node_text( "DisplayName" ) ; end
    def permission ; self.node_text( "Permission" ) ; end

    def grantees( type=:list ) ; self.nodes("Grantee" ) ; end

    protected
    def node_text( xpath )
      code = REXML::XPath.first( self, xpath )
      code.to_s.empty? ? '' : code.text
    rescue
#      puts "XPath #{xpath} on #{self.to_s} resulted in #{$!.class.name}: #{$!.message}\n#{$!.backtrace.join("\n")}"
      raise $!
    end
    
    def nodes( xpath )
      REXML::XPath.match( self, xpath )
    end
  end
  
end

Dir[File.join( File.join( File.dirname( __FILE__ ), 'sqs' ), "*.rb" )].each { |f| require f }

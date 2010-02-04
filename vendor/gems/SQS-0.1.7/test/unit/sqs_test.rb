#!/usr/local/bin/ruby

require 'test/unit'
require "#{File.expand_path( File.dirname( __FILE__ ) )}/test_setup"

class DuckTypeParameter
  def initialize( st )
    @st = st
  end

  def to_s
    @st
  end
end



class SQSTest < Test::Unit::TestCase
  def setup
    @used_prefixes ||= {}

    @queue_prefix = "testSQS#{rand( 10040932 )}"
    @queue_prefix = "testSQS#{rand( 10040932 )}" while @used_prefixes[@queue_prefix]

    @used_prefixes[@queue_prefix] = true

    unless SQStest.skip_live_tests?
      @original_access_key_id = SQS.access_key_id
      @original_secret_access_key = SQS.secret_access_key

      @q = SQS.create_queue( @queue_prefix )
    end
    
    SQS.add_reasons_to_retry 'ServiceUnavailable'
    SQS.remove_reasons_to_retry( SQS.reasons_to_retry.reject { |r| r == 'ServiceUnavailable' } )
    SQS.retry_attempts = 10

  end
  def teardown
    unless SQStest.skip_live_tests?
      SQS.access_key_id = @original_access_key_id
      SQS.secret_access_key = @original_secret_access_key

      SQS.list_queues( @queue_prefix ).each do |q|
        begin
          q.delete! if q.exists?
        rescue SQS::AWSSimpleQueueServiceNonExistentQueue
          # Note that it's possible that the queue existed in
          # the exists? clause, but does not exist in the delete clause
        end
      end
    end
    print SQS.counter if SQStest.print_counter?

  end

  unless SQStest.skip_live_tests?
    def test_list_queues
      assert_respond_to SQS, :list_queues
      queues = SQS.list_queues
      assert_kind_of Array, queues
      queues.each do |queue|
        assert_kind_of SQS::Queue, queue
      end

      SQS.create_queue( "#{@queue_prefix}A1" )
      SQS.create_queue( "#{@queue_prefix}A2" )
      SQS.create_queue( "#{@queue_prefix}B1" )
      SQS.create_queue( "#{@queue_prefix}B2" )

      assert_equal 5, SQS.list_queues( :prefix => @queue_prefix ).size
      assert_equal 2, SQS.list_queues( :prefix => "#{@queue_prefix}A" ).size
      assert_equal 2, SQS.list_queues( :prefix => "#{@queue_prefix}B" ).size
    end

    def test_each_queue
      assert_respond_to SQS, :each_queue
      SQS.each_queue do |q|
        assert_kind_of SQS::Queue, q
      end
    end

    def test_get_queue
      assert_respond_to SQS, :get_queue

      queuename = "#{@queue_prefix}something"
      q1 = SQS.create_queue( queuename )
      q2 = SQS.get_queue( queuename )

      assert q1.is_a?( SQS::Queue )
      assert q2.is_a?( SQS::Queue )
      assert_equal q1, q2
      
      assert_raises SQS::UnavailableQueue do
        SQS.get_queue( "SHOULD_NEVER_EXIST" )
      end
    end

    def test_get_non_existent_queue
      assert_respond_to SQS, :get_queue

      queuename = "#{@queue_prefix}nonexist"
      assert_raises SQS::UnavailableQueue do
        q2 = SQS.get_queue( queuename )
      end
    end

    def test_create_queue
      assert_respond_to SQS, :create_queue
      assert_equal false, SQS.create_queue
      assert_nothing_raised do
         SQS.create_queue( "#{@queue_prefix}#{rand( 100000 )}" )
      end
      q = SQS.create_queue( "#{@queue_prefix}#{rand( 100000 )}" )
      assert_kind_of( SQS::Queue, q )
    end

    def test_call_web_service
      begin
        SQS.call_web_service( :Something => 'for nothing' )
      rescue
        assert_equal 'SQS::MissingParameter', $!.class.name
      else
        flunk "Was supposed to raise an SQS::InvalidAction"
      end

      x = nil
      assert_nothing_raised do
        x = SQS.call_web_service( :Action => 'ListQueues' )
      end
      assert_equal REXML::Document, x.class
    end
  end
  
  def test_bad_conf_file
    assert_nothing_raised do
      SQS.conf_file = 'Should-not-exist.ext'
    end
  end

  def test_good_conf_file
    f = File.expand_path( File.join( File.dirname( __FILE__ ), 'test_conf.yml' ) )
    
    assert_not_equal f, SQS.conf_file
    assert_not_equal 'number 5', SQS.access_key_id
    assert_not_equal 'is alive', SQS.secret_access_key

    SQS.conf_file = File.join( File.dirname( __FILE__ ), 'test_conf.yml' )

    assert_equal f, SQS.conf_file
    assert_equal 'number 5', SQS.access_key_id
    assert_equal 'is alive', SQS.secret_access_key
  end
  
  def test_get_exception_class
    assert_raises ArgumentError do
      SQS.get_exception_class
    end
    assert_raises ArgumentError do
      SQS.get_exception_class( nil )
    end
    
    assert_nothing_raised do
      SQS.get_exception_class( 'Crazy' )
    end
    assert_equal Class, SQS.get_exception_class( 'Crazy' ).class
    assert_equal 'SQS::Crazy', SQS.get_exception_class( 'Crazy' ).name

    assert_equal Class, SQS.get_exception_class( 'good For Nothing' ).class
    assert_equal 'SQS::GoodForNothing', SQS.get_exception_class( 'good For Nothing' ).name

    assert_equal Class, SQS.get_exception_class( 'good.For.Nothing' ).class
    assert_equal 'SQS::GoodForNothing', SQS.get_exception_class( 'good.For.Nothing' ).name

    assert_equal Class, SQS.get_exception_class( '&(#Sunday)99' ).class
    assert_equal 'SQS::Sunday99', SQS.get_exception_class( '&(#Sunday)99' ).name
  end
  def test_get_exception
    assert_raises ArgumentError do
      SQS.get_exception
    end
    assert_raises ArgumentError do
      SQS.get_exception( 9 )
    end
    assert_raises ArgumentError do
      SQS.get_exception( 'Thursday' )
    end
    assert_raises ArgumentError do
      SQS.get_exception( {} )
    end

    e = SQS.get_exception( :url => "I'm a URL!", :document => REXML::Document.new( "<?xml version='1.0'?><Response><Errors><Error><Code>ServiceUnavailable</Code><Message>Service Queue is currently unavailable. Please try again later</Message></Error></Errors><RequestID>6847ea9e-af25-4fc7-9974-75b6bef82581</RequestID></Response>" ) )
    assert_equal 'SQS::ServiceUnavailable', e.class.name
    assert_match /^Service Queue is currently unavailable\. Please try again later \(The XML/, e.message

    e = SQS.get_exception( :attempts => 0, :url => "I'm a URL!", :document => REXML::Document.new( "<?xml version='1.0'?><Response><Errors><Error><Code>ServiceUnavailable</Code><Message>Service Queue is currently unavailable. Please try again later</Message></Error></Errors><RequestID>6847ea9e-af25-4fc7-9974-75b6bef82581</RequestID></Response>" ) )
    assert_equal 'SQS::ServiceUnavailable', e.class.name
    assert_match /^Service Queue is currently unavailable\. Please try again later \(The XML/, e.message

    e = SQS.get_exception( :attempts => 1, :url => "I'm a URL!", :document => REXML::Document.new( "<?xml version='1.0'?><Response><Errors><Error><Code>ServiceUnavailable</Code><Message>Service Queue is currently unavailable. Please try again later</Message></Error></Errors><RequestID>6847ea9e-af25-4fc7-9974-75b6bef82581</RequestID></Response>" ) )
    assert_equal 'SQS::ServiceUnavailable', e.class.name
    assert_match /^Service Queue is currently unavailable\. Please try again later \(After 1 attempt\) \(The XML/, e.message

    e = SQS.get_exception( :attempts => 2, :url => "I'm a URL!", :document => REXML::Document.new( "<?xml version='1.0'?><Response><Errors><Error><Code>ServiceUnavailable</Code><Message>Service Queue is currently unavailable. Please try again later</Message></Error></Errors><RequestID>6847ea9e-af25-4fc7-9974-75b6bef82581</RequestID></Response>" ) )
    assert_equal 'SQS::ServiceUnavailable', e.class.name
    assert_match /^Service Queue is currently unavailable\. Please try again later \(After 2 attempts\) \(The XML/, e.message
  end

  def test_counter
    initial_counter = SQS.counter
    assert SQS.reset_counter
    assert_equal 0, SQS.counter
    
    (1..10).to_a.each do |i|
      assert SQS.increment_counter
    end
    assert_equal 10, SQS.counter
    assert SQS.reset_counter
    assert_equal 0, SQS.counter
    
    while SQS.counter < initial_counter do
      SQS.increment_counter
    end
    assert_equal initial_counter, SQS.counter
  end


  def test_case_insensitivity_of_prepare_parameters_for_signing
    assert_equal 1, 'a' <=> 'B'
    assert_equal -1, 'a' <=> 'b'
    assert_equal 'aaBB', SQS.prepare_parameters_for_signing( :a => 'a', :B => 'B' )
    assert_equal 'aaBB', SQS.prepare_parameters_for_signing( :B => 'B', :a => 'a' )
    assert_equal 'aabb', SQS.prepare_parameters_for_signing( :a => 'a', :b => 'b' )
    assert_equal 'aabb', SQS.prepare_parameters_for_signing( :b => 'b', :a => 'a' )
  end
  def test_prepare_parameters_for_signing
    assert_equal 'bobBOB', SQS.prepare_parameters_for_signing( :bob => 'BOB' )
    assert_equal 'BOBbob', SQS.prepare_parameters_for_signing( :BOB => 'bob' )
    assert_equal 'appleOrangeApricotsoranges', SQS.prepare_parameters_for_signing( :Apricots => 'oranges', :apple => 'Orange' )
  end
  def test_prepare_ducktype_values_for_signing
    assert_equal 'bobBOB', SQS.prepare_parameters_for_signing( :bob => DuckTypeParameter.new( 'BOB' ) )
    assert_equal 'BOBbob', SQS.prepare_parameters_for_signing( :BOB => DuckTypeParameter.new( 'bob' ) )
    assert_equal 'appleOrangeApricotsoranges', SQS.prepare_parameters_for_signing( :Apricots => DuckTypeParameter.new( 'oranges' ), :apple => DuckTypeParameter.new( 'Orange' ) )
  end
  def test_prepare_ducktype_keys_for_signing
    assert_equal 'bobBOB', SQS.prepare_parameters_for_signing( DuckTypeParameter.new( 'bob' ) => 'BOB' )
    assert_equal 'BOBbob', SQS.prepare_parameters_for_signing( DuckTypeParameter.new( 'BOB' ) => 'bob' )
    assert_equal 'appleOrangeApricotsoranges', SQS.prepare_parameters_for_signing( DuckTypeParameter.new( 'Apricots' ) => 'oranges', DuckTypeParameter.new( 'apple' ) => 'Orange' )
  end

  def test_url_for_query
    assert_respond_to SQS, :url_for_query
    assert_equal 'http://queue.amazonaws.com/', SQS.url_for_query
  end

  def test_create_signature
    assert_respond_to SQS, :create_signature
    params = { :you => 'crazy' }
    assert !SQS.create_signature( params ).nil?
  end

  def test_initialize_returns_class_not_instance
    assert_equal 'Class', SQS.new.class.to_s
    assert_equal 'SQS', SQS.new.name.to_s
  end

  def test_api_version
    assert_respond_to SQS, :api_version
    assert_equal '2007-05-01', SQS.api_version
  end


  def test_access_key_id
    assert SQS.respond_to?( :access_key_id )
    assert SQS.respond_to?( :access_key_id= )
    i = SQS.access_key_id
    assert SQS.access_key_id = 'Something freaky'
    assert_not_equal 'Replace this with your access key id', SQS.access_key_id, 'Please change the access key id'
    SQS.access_key_id = i
  end
  
  def test_secret_access_key
    assert SQS.respond_to?( :secret_access_key )
    assert SQS.respond_to?( :secret_access_key= )
    k = SQS.secret_access_key
    assert SQS.secret_access_key = 'Something freaky'
    assert_not_equal 'Replace this with your secret access key', SQS.secret_access_key, 'Please change the secret access key.'
    SQS.secret_access_key = k
  end



  def test_params_for_query
    assert_respond_to SQS, :params_for_query
    t = Time.now

    assert_equal_hashes(
      { :Version => SQS.api_version, :AWSAccessKeyId => SQS.access_key_id, :SignatureVersion => SQS.signature_version, :Expires => t.to_iso8601, :DefaultVisibilityTimeout => SQS::Queue.default_visibility_timeout },
      SQS.params_for_query( t )
    )

    assert_equal_hashes(
      { :Version => SQS.api_version, :AWSAccessKeyId => SQS.access_key_id, :SignatureVersion => SQS.signature_version, :Expires => ( Time.now + SQS.request_ttl ).to_iso8601, :DefaultVisibilityTimeout => SQS::Queue.default_visibility_timeout },
      SQS.params_for_query
    )
  end

  def test_signature_version
    assert_respond_to SQS, :signature_version
    assert_equal 1, SQS.signature_version
  end

  def test_request_ttl
    assert_respond_to SQS, :request_ttl
    assert_kind_of Integer, SQS.request_ttl
  end

  def test_retry_attempts
    assert_respond_to SQS, :retry_attempts
    assert_kind_of Integer, SQS.retry_attempts
    assert 1 <= SQS.retry_attempts
  end

  def test_change_retry_attempts
    assert_respond_to SQS, :retry_attempts=

    assert_raises ArgumentError do
      SQS.retry_attempts = Object
    end
    assert_equal 10, SQS.retry_attempts

    assert_nothing_raised ArgumentError do
      SQS.retry_attempts = nil
    end
    assert_equal 0, SQS.retry_attempts

    assert_nothing_raised do
      SQS.retry_attempts = 2
    end
    assert_equal 2, SQS.retry_attempts
  end


  def test_reasons_to_retry
    assert_respond_to SQS, :reasons_to_retry
    assert_kind_of Array, SQS.reasons_to_retry
    assert_equal ['ServiceUnavailable'], SQS.reasons_to_retry
  end

  def test_add_reasons_to_retry
    assert_respond_to SQS, :add_reasons_to_retry
    assert_respond_to SQS, :add_reasons_to_retry

    assert_raises ArgumentError do
      SQS.add_reasons_to_retry
    end

    assert_raises ArgumentError do
      SQS.add_reasons_to_retry( nil )
    end
    assert_equal ['ServiceUnavailable'], SQS.reasons_to_retry

    assert_nothing_raised do
      SQS.add_reasons_to_retry( 'ServiceUnavailable' )
    end
    assert_equal ['ServiceUnavailable'], SQS.reasons_to_retry

    assert_nothing_raised do
      SQS.add_reasons_to_retry( 'a' )
    end
    assert_equal ['ServiceUnavailable', 'a'], SQS.reasons_to_retry


    assert_nothing_raised do
      SQS.add_reasons_to_retry( 'b', 'c' )
    end
    assert_equal ['ServiceUnavailable', 'a', 'b', 'c' ], SQS.reasons_to_retry

    assert_nothing_raised do
      SQS.add_reasons_to_retry( ['d', 'e'] )
    end
    assert_equal ['ServiceUnavailable', 'a', 'b', 'c', 'd', 'e' ], SQS.reasons_to_retry
  end

  def test_remove_reasons_to_retry
    assert_respond_to SQS, :remove_reasons_to_retry
    assert_respond_to SQS, :remove_reason_to_retry

    assert_nothing_raised do
      SQS.add_reasons_to_retry( 'a', 'b', 'c', 'd', 'e' )
    end
    assert_equal ['ServiceUnavailable', 'a', 'b', 'c', 'd', 'e' ], SQS.reasons_to_retry
      

    assert_raises ArgumentError do
      SQS.remove_reasons_to_retry
    end

    assert_raises ArgumentError do
      SQS.remove_reasons_to_retry( nil )
    end
    assert_equal ['ServiceUnavailable', 'a', 'b', 'c', 'd', 'e' ], SQS.reasons_to_retry

    assert_nothing_raised do
      SQS.remove_reasons_to_retry( 'ServiceUnavailable' )
    end
    assert_equal ['a', 'b', 'c', 'd', 'e' ], SQS.reasons_to_retry

    assert_nothing_raised do
      SQS.remove_reasons_to_retry( 'a' )
    end
    assert_equal ['b', 'c', 'd', 'e' ], SQS.reasons_to_retry


    assert_nothing_raised do
      SQS.remove_reasons_to_retry( 'b', 'c' )
    end
    assert_equal ['d', 'e' ], SQS.reasons_to_retry

    assert_nothing_raised do
      SQS.remove_reasons_to_retry( ['d', 'e'] )
    end
    assert SQS.reasons_to_retry.empty?
  end


  def test_iso8601
    t = Time.now
    assert_respond_to t, :to_iso8601
    assert_equal t.utc.strftime( "%Y-%m-%dT%H:%M:%SZ" ), t.to_iso8601
  end

  def test_request_expires
    t = Time.now
    assert_respond_to t, :request_expires
    assert_equal t.request_expires, t + SQS.request_ttl
  end

  def test_xpath
    d = REXML::Document.new( "<?xml version='1.0'?><CreateQueueResponse xmlns='http://queue.amazonaws.com/doc/2006-04-01/'><QueueUrl>http://queue.amazonaws.com/A3ZVJ8HH1F466/nothing</QueueUrl><ResponseStatus><StatusCode>Success</StatusCode><RequestId>945de8b9-a820-4329-a56e-211053d89d0b</RequestId></ResponseStatus></CreateQueueResponse>" )
    assert_equal 'Success', d.status
    assert_equal 'http://queue.amazonaws.com/A3ZVJ8HH1F466/nothing', d.queue_url


    d = REXML::Document.new( "<?xml version='1.0'?><Response><Errors><Error><Code>AuthFailure</Code><Message>AWS was not able to authenticate the request: access credentials are missing</Message></Error></Errors><RequestID>8f6707de-db6e-4bf7-909c-8dd6486bd42f</RequestID></Response>" )
    assert_equal 'AuthFailure', d.error_code
    assert_equal 'AWS was not able to authenticate the request: access credentials are missing', d.error_message


    d = REXML::Document.new( "<?xml version='1.0'?><ListQueuesResponse xmlns='http://queue.amazonaws.com/doc/2006-04-01/'><QueueUrl>http://queue.amazonaws.com/A3ZVJ8HH1F466/nothing</QueueUrl><ResponseStatus><StatusCode>Success</StatusCode><RequestId>c2d4fe0b-f6f1-4874-9e6d-d081a1155b54</RequestId></ResponseStatus></ListQueuesResponse>" )
    assert_equal 'Success', d.status


    d = REXML::Document.new( "<?xml version='1.0'?><ListQueuesResponse xmlns='http://queue.amazonaws.com/doc/2006-04-01/'><QueueUrl>http://queue.amazonaws.com/A3ZVJ8HH1F466/nothingAgain</QueueUrl><QueueUrl>http://queue.amazonaws.com/A3ZVJ8HH1F466/nothing</QueueUrl><ResponseStatus><StatusCode>Success</StatusCode><RequestId>e27b54da-ff38-413b-b52f-82a6342cd151</RequestId></ResponseStatus></ListQueuesResponse>" )
    assert_equal 'Success', d.status
    assert_equal 'e27b54da-ff38-413b-b52f-82a6342cd151', d.request_id


    d = REXML::Document.new( "<?xml version='1.0'?><SendMessageResponse xmlns='http://queue.amazonaws.com/doc/2006-04-01/'><MessageId>171Q1105D8GTGS9FR4QB|9CBMKVD6TTQX44QJ1S30|PT6DRTB278S4MNY77NJ0</MessageId><ResponseStatus><StatusCode>Success</StatusCode><RequestId>ddbab3dc-3910-4c86-a139-27e37cabeac4</RequestId></ResponseStatus></SendMessageResponse>" )
    assert_equal '171Q1105D8GTGS9FR4QB|9CBMKVD6TTQX44QJ1S30|PT6DRTB278S4MNY77NJ0', d.message_id( :send )
    assert_equal 'Success', d.status
    assert_equal 'ddbab3dc-3910-4c86-a139-27e37cabeac4', d.request_id


    d = REXML::Document.new( "<?xml version='1.0'?><PeekMessageResponse xmlns='http://queue.amazonaws.com/doc/2006-04-01/'><Message><MessageId>1WB69MM74V13FFJRTA65|3H4AA8J7EJKM0DQZR7E1|9CBMKVD6TTQX44QJ1S30</MessageId><MessageBody>what it is</MessageBody></Message><ResponseStatus><StatusCode>Success</StatusCode><RequestId>c23c96f4-6479-48d3-b1e4-158ebfe0cc17</RequestId></ResponseStatus></PeekMessageResponse>" )
    assert_equal 'what it is', d.message_body
    assert_equal '1WB69MM74V13FFJRTA65|3H4AA8J7EJKM0DQZR7E1|9CBMKVD6TTQX44QJ1S30', d.message_id( :peek )
    assert_equal 'Success', d.status
    assert_equal 'c23c96f4-6479-48d3-b1e4-158ebfe0cc17', d.request_id


    d = REXML::Document.new( "<?xml version='1.0'?><ReceiveMessageResponse xmlns='http://queue.amazonaws.com/doc/2006-04-01/'><Message><MessageId>0C2GG4PAQACB5REHPA7W|3H4AA8J7EJKM0DQZR7E1|9CBMKVD6TTQX44QJ1S30</MessageId><MessageBody>you are silly person</MessageBody></Message><ResponseStatus><StatusCode>Success</StatusCode><RequestId>a901d3ec-24b6-4125-9345-36f01cd82021</RequestId></ResponseStatus></ReceiveMessageResponse>" )
    assert_equal 'you are silly person', d.message_body( :receive )
    assert_equal '0C2GG4PAQACB5REHPA7W|3H4AA8J7EJKM0DQZR7E1|9CBMKVD6TTQX44QJ1S30', d.message_id( :receive )
    assert_equal 'Success', d.status
    assert_equal 'a901d3ec-24b6-4125-9345-36f01cd82021', d.request_id


    d = REXML::Document.new( "<?xml version='1.0'?><ReceiveMessageResponse xmlns='http://queue.amazonaws.com/doc/2006-04-01/'><Message><MessageId>0C2GG4PAQACB5REHPA7W|3H4AA8J7EJKM0DQZR7E1|9CBMKVD6TTQX44QJ1S30</MessageId><MessageBody>you are silly person</MessageBody></Message><Message><MessageId>12ZJQSDVXE728WJBXACC|3H4AA8J7EJKM0DQZR7E1|9CBMKVD6TTQX44QJ1S30</MessageId><MessageBody>whatever</MessageBody></Message><Message><MessageId>15YJSSXZ2R5XB0T1PXMY|3H4AA8J7EJKM0DQZR7E1|PT6DRTB278S4MNY77NJ0</MessageId><MessageBody>whatever</MessageBody></Message><Message><MessageId>0BRPBSW05BB9Z6HXWV4J|3H4AA8J7EJKM0DQZR7E1|9CBMKVD6TTQX44QJ1S30</MessageId><MessageBody>whatever</MessageBody></Message><ResponseStatus><StatusCode>Success</StatusCode><RequestId>ebf56590-665f-4077-8820-953c6663d220</RequestId></ResponseStatus></ReceiveMessageResponse>" )
    assert d.messages.is_a?( Array )
    d.messages.each do |m|
      assert m.respond_to?( :message_id )
      assert m.respond_to?( :message_body )
    end
    assert_equal 'Success', d.status
    assert_equal 'ebf56590-665f-4077-8820-953c6663d220', d.request_id

    d = REXML::Document.new( "<?xml version='1.0'?><GetVisibilityTimeoutResponse xmlns='http://queue.amazonaws.com/doc/2006-04-01/'><VisibilityTimeout>30</VisibilityTimeout><ResponseStatus><StatusCode>Success</StatusCode><RequestId>410fa43f-56f8-4e48-8c37-fa2f488f84aa</RequestId></ResponseStatus></GetVisibilityTimeoutResponse>" )
    assert_equal 30, d.visibility_timeout
    assert_equal 'Success', d.status
    assert_equal '410fa43f-56f8-4e48-8c37-fa2f488f84aa', d.request_id

    d = REXML::Document.new( "<?xml version='1.0'?><SetVisibilityTimeoutResponse xmlns='http://queue.amazonaws.com/doc/2006-04-01/'><ResponseStatus><StatusCode>Success</StatusCode><RequestId>26d8f4b9-a95a-4ead-85e0-a3c6ee642d64</RequestId></ResponseStatus></SetVisibilityTimeoutResponse>" )
    assert_equal 'Success', d.status
    assert_equal '26d8f4b9-a95a-4ead-85e0-a3c6ee642d64', d.request_id


    d = REXML::Document.new( "<?xml version='1.0'?><ListGrantsResponse xmlns='http://access.amazonaws.com/doc/2006-01-01/'><GrantList><Grantee xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xsi:type='CanonicalUser'><ID>2a3fad33685601e436445b8d283589b9d5ccd89a50da8fa91c664f2531ea5c71</ID><DisplayName>wzph</DisplayName></Grantee><Permission>FULLCONTROL</Permission></GrantList><ResponseStatus><StatusCode>Success</StatusCode></ResponseStatus></ListGrantsResponse>" )
    assert d.grant_lists.is_a?( Array )
    assert_equal 1, d.grant_lists.size
    d.grant_lists.each do |list|
      assert list.respond_to?( :permission )
      assert list.respond_to?( :grantees )
      list.grantees.each do |g|
        assert g.respond_to?( :id )
        assert g.respond_to?( :display_name )
        assert g.respond_to?( :permission )
      end
    end
    assert_equal 'Success', d.status

    d = REXML::Document.new( "<?xml version='1.0'?><ListGrantsResponse xmlns='http://access.amazonaws.com/doc/2006-01-01/'><GrantList><Grantee xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xsi:type='CanonicalUser'><ID>fde39a46472f20295511ed16510c2ff352e5d0cc0060e1aa3edfa77cbc6412bf</ID><DisplayName>lance3515</DisplayName></Grantee><Permission>RECEIVEMESSAGE</Permission></GrantList><GrantList><Grantee xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xsi:type='CanonicalUser'><ID>2a3fad33685601e436445b8d283589b9d5ccd89a50da8fa91c664f2531ea5c71</ID><DisplayName>wzph</DisplayName></Grantee><Permission>FULLCONTROL</Permission></GrantList><ResponseStatus><StatusCode>Success</StatusCode></ResponseStatus></ListGrantsResponse>" )
    assert d.grant_lists.is_a?( Array )
    assert_equal 2, d.grant_lists.size
    d.grant_lists.each do |list|
      assert list.respond_to?( :permission )
      assert list.respond_to?( :grantees )
      list.grantees.each do |g|
        assert g.respond_to?( :id )
        assert g.respond_to?( :display_name )
        assert g.respond_to?( :permission )
      end
    end
    assert_equal 'Success', d.status


    d = REXML::Document.new( "<?xml version='1.0'?><AddGrantResponse xmlns='http://access.amazonaws.com/doc/2006-01-01/'><ResponseStatus><StatusCode>Success</StatusCode></ResponseStatus></AddGrantResponse>" )
    assert_equal 'Success', d.status

    d = REXML::Document.new( "<?xml version='1.0'?><GetQueueAttributesResponse xmlns='http://queue.amazonaws.com/doc/2007-05-01/'><AttributedValue><Attribute>VisibilityTimeout</Attribute><Value>30</Value></AttributedValue><AttributedValue><Attribute>ApproximateNumberOfMessages</Attribute><Value>0</Value></AttributedValue><ResponseStatus><StatusCode>Success</StatusCode><RequestId>00ae54e4-0dc9-4835-bc2e-36304ff40506</RequestId></ResponseStatus></GetQueueAttributesResponse>" )
    assert d.attributed_values.is_a?( Array )
    assert_equal 2, d.attributed_values.size
#    d.attributed_values.each do |att|
#      puts att
#    end
    assert_equal 'Success', d.status
    
    
    
    d = REXML::Document.new( "<?xml version='1.0'?><ListQueuesResponse xmlns='http://queue.amazonaws.com/doc/2007-05-01/'><QueueUrl>http://queue.amazonaws.com/A3ZVJ8HH1F466/testSQS</QueueUrl><ResponseStatus><StatusCode>Success</StatusCode><RequestId>fd2d47e4-2cac-4047-94f2-e220d995835b</RequestId></ResponseStatus></ListQueuesResponse>" )
    assert_nothing_raised do
      d.status
    end
    assert_equal 'Success', d.status
    assert_equal '', d.error_code
    
  end


  def test_permissions
    assert_equal 'RECEIVEMESSAGE', SQS.permissions[:receive]
    assert_equal 'SENDMESSAGE', SQS.permissions[:send]
    assert_equal 'FULLCONTROL', SQS.permissions[:full]

    assert_equal 'RECEIVEMESSAGE', SQS.permissions( :receive )
    assert_equal 'SENDMESSAGE', SQS.permissions( :send )
    assert_equal 'FULLCONTROL', SQS.permissions( :full )

    assert_equal 'RECEIVEMESSAGE', SQS.permissions( 'RECEIVEMESSAGE' )
    assert_equal 'SENDMESSAGE', SQS.permissions( 'SENDMESSAGE' )
    assert_equal 'FULLCONTROL', SQS.permissions( 'FULLCONTROL' )
  end
end


module Test
  module Unit
    module Assertions
      public
      def assert_equal_hashes(hsh1, hsh2, message=nil)
        _wrap_assertion do
          assert_block( "assert_equal_hashes should not be called with a block." ) { !block_given? }
          assert_block( "assert_equal_hashes expects a hash, but got a #{hsh1.class.to_s} in first parameter." ) { hsh1.is_a?( Hash ) }
          assert_block( "assert_equal_hashes expects a hash, but got a #{hsh2.class.to_s} in second parameter." ) { hsh2.is_a?( Hash ) }
          assert_block( build_message( message, "<?> is not equal to <?>.", hsh1, hsh2 ) ) do
            hsh1 == hsh2
          end
        end
      end
    end
  end
end
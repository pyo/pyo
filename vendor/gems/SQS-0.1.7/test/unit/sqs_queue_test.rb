#!/usr/local/bin/ruby
dir = File.expand_path( File.dirname( __FILE__ ) )

require 'test/unit'
require "#{File.expand_path( File.dirname( __FILE__ ) )}/test_setup"

require 'rubygems'
require 'assert_statistically'

gem 'assert_statistically', '>= 0.2.1'

class SQS_QueueTest < Test::Unit::TestCase
  def self.other_aws_account
    SQStest.other_aws_account
  end
  
  def setup
    @used_prefixes ||= {}

    @queue_prefix = "test_queue_#{rand( 10040932 )}"
    @queue_prefix = "test_queue_#{rand( 10040932 )}" while @used_prefixes[@queue_prefix]

    @used_prefixes[@queue_prefix] = true

    if SQStest.skip_live_tests?
      @q = SQS::Queue.new( 'http://nowhere.com/nothing' )
    else
      @q = SQS.create_queue( @queue_prefix )

      unless @q.exists?
        assert_statistically( :of => 2, :after => lambda{ |i,s| sleep 0.25 } ) do
          begin
            @q = SQS.get_queue( @queue_prefix )
          rescue
            false
          else
            true
          end
        end
      end
    end
  end
  def teardown
    unless SQStest.skip_live_tests?
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

    def test_delete
      assert @q.is_a?( SQS::Queue )
      q2 = SQS.get_queue( @queue_prefix )
      assert q2.is_a?( SQS::Queue )
      assert_equal @q, q2

      assert @q.delete

      # Per the specs, it can take 60 seconds to delete a queue.  Argh.
      # http://docs.amazonwebservices.com/AWSSimpleQueueService/2007-05-01/SQSDeveloperGuide/
      # See API Reference -> Query and SOAP API Reference -> DeleteQueue
      sleep 60

      begin
        q3 = SQS.get_queue( @queue_prefix )
      rescue
        assert_equal 'SQS::UnavailableQueue', $!.class.name
      else
        flunk 'Was supposed to raise an SQS::UnavailableQueue'
      end

      begin
        q2.delete
      rescue
        assert_equal 'SQS::AWSSimpleQueueServiceNonExistentQueue', $!.class.name
      else
        flunk 'Was supposed to raise an SQS::AWSSimpleQueueServiceNonExistentQueue'
      end

      q = SQS.create_queue :name => "#{@queue_prefix}test_delete"
      q.send_message( 'A' )
      q.send_message( 'B' )
      begin
        q.delete
      rescue
        assert_equal 'SQS::AWSSimpleQueueServiceNonEmptyQueue', $!.class.name
      else
        flunk 'Was supposed to raise an SQS::AWSSimpleQueueServiceNonEmptyQueue'
      end
      assert_nothing_raised do
        q.delete( :force => true )
      end
    end
    
    def test_delete!
      @q.send_message( 'A' )
      @q.send_message( 'B' )
      begin
        @q.delete
      rescue
        assert_equal 'SQS::AWSSimpleQueueServiceNonEmptyQueue', $!.class.name
      else
        asssert false, "Was supposed to raise an SQS::AWSSimpleQueueServiceNonEmptyQueue"
      end
      assert_nothing_raised do
        @q.delete!
      end

      assert_statistically( :of => 3, :after => lambda{ |i,s| sleep 3 } ) do
        begin
          q = SQS.get_queue( @queue_prefix )
        rescue
          'SQS::UnavailableQueue' == $!.class.name
        else
          false
        end
      end
    end

    def test_force_delete
      (1..10).to_a.each do |i|
        @q.send_message( "I am receiving message ##{i}" )
      end

      assert_statistically( :of => 3, :after => lambda{ |i,s| sleep( i * 5 ) } ) do
        begin
          @q.delete
        rescue
          'SQS::AWSSimpleQueueServiceNonEmptyQueue' == $!.class.name
        else
          false
        end
      end
    
      assert_nothing_raised do
        @q.force_delete
      end
      
      assert_statistically( :of => 3, :after => lambda{ |i,s| sleep( i * 0.5 ) } ) do
        begin
          q = SQS.get_queue( @queue_prefix )
        rescue
          'SQS::UnavailableQueue' == $!.class.name
        else
          false
        end
      end
    end

    def test_exist
      assert @q.exist?
      assert @q.exists?
      q2 = SQS.get_queue( @queue_prefix )
      assert q2.exists?
      assert q2.exist?

      assert @q.delete

      # Per the specs, it can take 60 seconds to delete a queue.  Argh.
      # http://docs.amazonwebservices.com/AWSSimpleQueueService/2007-05-01/SQSDeveloperGuide/
      # See API Reference -> Query and SOAP API Reference -> DeleteQueue
      assert_statistically( :of => 6, :before => lambda{ |i,s| sleep 10 } ) do
        !( @q.exists? || @q.exist? || q2.exists? || q2.exist? )
      end

      q3 = SQS::Queue.new( 'http://borker.borked/borkee' )
      assert !q3.exists?
      assert !q3.exist?
    end

    def test_send_message
      m = @q.send_message( 'This is so mething special' )
      assert m.is_a?( SQS::Message )
      assert_equal @q, m.queue
    end
    
    def test_send_big_message
      message = ''
      6000.times do
        message << 'x'
      end
      assert @q.send_message( message )
      #Note that this is as big as I can reliably get right now
      #Need to do some debugging, because I keep getting EOFErrors
      #when I submit a message of size 7867 (roughly) or above
      #
      #Also, the Amazon API allows you to post a body to a URL
      # with query parameters in it, to send a message up to 256K
      # in length. Something to consider.
    end

    def test_get_and_set_queue_attributes
      assert @q.attributes.empty?
      assert @q.get_queue_attributes
      assert !@q.attributes.empty?
      assert_equal 0, @q.attributes[:ApproximateNumberOfMessages]
      assert_equal 30, @q.attributes[:VisibilityTimeout]
      
      assert @q.set_queue_attributes( :VisibilityTimeout => 400 )
      assert_equal 400, @q.attributes[:VisibilityTimeout]
      assert_equal 0, @q.attributes[:ApproximateNumberOfMessages]
      assert_nothing_raised do
        @q.get_queue_attributes( true )
      end
      assert_statistically( :of => 10, :after => lambda{ |i,s| sleep( i * 0.25 ) } ) do
        @q.get_queue_attributes( true )
        400 == @q.attributes[:VisibilityTimeout]
      end
      assert_equal 0, @q.attributes[:ApproximateNumberOfMessages]


      begin
        @q.set_queue_attributes( :SHOULDBEANERROR => 'crazy!' )
      rescue
        assert_equal 'SQS::InvalidAttributeName', $!.class.name
      else
        flunk 'Was supposed to raise an SQS::InvalidAttributeName'
      end
    end
    
    
    def test_no_such_method
      assert_raises NoMethodError do
        @q.no_such_method
      end
    end

    def test_approximate_number_of_messages
      assert_nothing_raised do
        @q.approximate_number_of_messages
      end
      assert_equal 0, @q.approximate_number_of_messages
      
      1.upto( 25 ) do |i|
        @q.send_message( "sending message #{i}" )
      end

      assert_equal 0, @q.approximate_number_of_messages
      assert_in_delta 25, @q.approximate_number_of_messages( true ), 3
    end


    def test_visibility_timeout
      assert_nothing_raised do
        @q.visibility_timeout
      end
      assert_equal 30, @q.visibility_timeout
      
      assert_nothing_raised do
        @q.visibility_timeout = 500
      end
      
      # Update happens in situ
      assert_equal 500, @q.visibility_timeout
      assert_statistically( :of => 10, :after => lambda{ |i,s| sleep( i * 0.5 ) } ) do
        @q.visibility_timeout( true ) == 500
      end
    end

    def test_empty?
      assert @q.empty?

      @q.send_message( 'no longer empty' )
      assert_statistically( :of => 3, :after => lambda{ |i,s| sleep( i * 0.5 ) } ) do
        !@q.empty?
      end

      @q.send_message( 'no longer empty again' )

      assert_statistically( :of => 3, :after => lambda{ |i,s| sleep 0.5 } ) do
        !@q.empty?
      end

      while m = @q.receive_message
        m.delete
        sleep 1
      end

      assert_statistically( :of => 3, :after => lambda{ |i,s| sleep( i * 1 ) }, :message => 'Attempt %d failed' ) do
        @q.empty?
      end
    end


    def test_peek_message
      @q.send_message( 'I am receiving a message from beyond' )

      m = nil
      assert_statistically( :of => 3, :after => lambda{ |i,s| sleep( i * 3 ) } ) do
        m = @q.peek_message
        m.is_a?( SQS::Message )
      end
      assert_equal @q, m.queue
      assert_equal 'I am receiving a message from beyond', m.body
      
      m2 = nil
      assert_statistically( :of => 3, :after => lambda{ |i,s| sleep 0.5 } ) do
        m2 = @q.receive_message
        m2.is_a?( SQS::Message )
      end
      assert_equal m.id, m2.id
      assert_equal m.body, m2.body
    end
    def test_peek_message_on_empty_queue
      m = @q.peek_message

      assert m.nil?
    end

    def test_peek_messages
      (1..10).to_a.each do |i|
        @q.send_message( "I am receiving message #{i}" )
      end

      messages = nil
      assert_statistically( :of => 3, :after => lambda{ |i,s| sleep( i * 0.5 ) } ) do
        messages = @q.peek_messages :count => 2
        messages.size == 1 || messages.size == 2
      end

      assert messages.is_a?( Array )
      messages.each do |m|
        assert m.is_a?( SQS::Message )
        assert_equal @q, m.queue
        assert_match /^I am receiving message \d+$/, m.body
      end

      messages = @q.peek_messages :count => 12
      assert messages.is_a?( Array )
      assert messages.size > 0 && messages.size < 12, "Weird array size: #{messages.size}"

      assert_statistically( :of => 3, :after => lambda{ |i,s| sleep( i * 0.5 ) } ) do
        messages = @q.receive_messages :count => 12
        messages.is_a?( Array ) && messages.size > 0 && messages.size < 12
      end
    end

    def test_receive_message
      @q.send_message( 'I am receiving a message from beyond' )

      m = nil
      assert_statistically( :of => 3, :after => lambda{ |i,s| sleep( i * 0.5 ) } ) do
        m = @q.receive_message
        m.is_a?( SQS::Message )
      end

      assert_equal @q, m.queue
      assert_equal 'I am receiving a message from beyond', m.body
    end
    def test_receive_message_on_empty_queue
      m = @q.receive_message

      assert m.nil?
    end

    def test_receive_messages
      (1..10).to_a.each do |i|
        @q.send_message( "I am receiving message #{i}" )
      end

      messages = nil
      assert_statistically( :of => 3, :after => lambda{ |i,s| sleep( i * 0.5 ) } ) do
        messages = @q.receive_messages :count => 2
        messages.size == 1 || messages.size == 2
      end

      assert messages.is_a?( Array )
      messages.each do |m|
        assert m.is_a?( SQS::Message )
        assert_equal @q, m.queue
        assert_match /^I am receiving message \d+$/, m.body
      end

      messages = @q.receive_messages :count => 12
      assert messages.is_a?( Array )
      assert messages.size > 0 && messages.size < 12, "Weird array size: #{messages.size}"
    end

    class DUMMY
      def self.email
        SQS_QueueTest::other_aws_account[:email]
      end
    end
    
    def test_add_grant
      assert_respond_to @q, :add_grant

      assert_equal 1, @q.list_grants.size

      assert @q.add_grant( :email => SQStest.other_aws_account[:email], :permission => :send )
      assert_statistically( :of => 6, :after => lambda{ |i,s| sleep 5 } ) do
        grants = @q.list_grants
        2 == grants.size
      end

      assert @q.add_grant( :email => SQStest.other_aws_account[:email], :permission => :receive )
      assert_statistically( :of => 6, :after => lambda{ |i,s| sleep 5 } ) do
        grants = @q.list_grants
        3 == grants.size
      end

      assert @q.add_grant( :email => SQStest.other_aws_account[:email], :permission => :full )
      assert_statistically( :of => 6, :after => lambda{ |i,s| sleep i < 5 ? 5 : 10 } ) do
        grants = @q.list_grants
        4 == grants.size
      end
      
      assert_nothing_raised do
        #DUMMY responds to :email (is not an address itself)
        @q.add_grant( :email => DUMMY, :permission => :receive )
      end
      assert_statistically( :of => 6, :after => lambda{ |i,s| sleep 5 } ) do
        grants = @q.list_grants
        4 == grants.size
      end
      
      begin
        @q.add_grant( :email => 'invalid@email.address', :permission => :receive )
      rescue
        assert_equal 'SQS::InvalidParameterValue', $!.class.name
      else
        flunk "Was supposed to raise an SQS::InvalidParameterValue"
      end
    end

    def test_remove_grant
      assert_respond_to @q, :remove_grant

      [:full, :send, :receive].each do |perm|
        assert_raises ArgumentError do
          @q.remove_grant( :permission => perm )
        end
      end



      [:full, :send, :receive].each do |perm|
        assert @q.add_grant( :email => SQStest.other_aws_account[:email], :permission => perm )
      end
      @q.list_grants.each do |g|
        unless g.display_name == SQStest.my_aws_account[:display_name]
          assert @q.remove_grant( :email => SQStest.other_aws_account[:email], :permission => g.permission )
        end
      end

      [:full, :send, :receive].each do |perm|
        assert @q.add_grant( :email => SQStest.other_aws_account[:email], :permission => perm )
      end
      @q.list_grants.each do |g|
        unless g.display_name == SQStest.my_aws_account[:display_name]
          #DUMMY responds to :email (is not an address itself)
          assert @q.remove_grant( :email => DUMMY, :permission => g.permission )
        end
      end

      [:full, :send, :receive].each do |perm|
        assert @q.add_grant( :email => SQStest.other_aws_account[:email], :permission => perm )
      end
      @q.list_grants.each do |g|
        unless g.display_name == SQStest.my_aws_account[:display_name]
          assert @q.remove_grant( :id => g.id, :permission => g.permission )
        end
      end

      [:full, :send, :receive].each do |perm|
        assert @q.add_grant( :email => SQStest.other_aws_account[:email], :permission => perm )
      end
      @q.list_grants.each do |g|
        unless g.display_name == SQStest.my_aws_account[:display_name]
          # the grant responds to :id (is not an id itself)
          assert @q.remove_grant( :id => g, :permission => g.permission )
        end
      end
    end

    def test_SQS_thread_15798
      # See http://developer.amazonwebservices.com/connect/thread.jspa?threadID=15798
      
      # Add a receive permission
      @q.add_grant( :email => SQStest.other_aws_account[:email], :permission => :receive)

      # There should be two total
      grants = nil
      assert_statistically( :of => 4, :after => lambda{ |i,s| sleep( i * 0.25 ) } ) do
        grants = @q.list_grants
        2 == grants.size
      end

      # There should be one send (my account)
      grants = @q.list_grants( :permission => :send )
      assert_equal 1, grants.size
      grants.each do |g|
        assert_kind_of SQS::Grant, g
        assert_equal SQStest.my_aws_account[:display_name], g.display_name
      end

      # There should be one receive and it should be the other users
      grants = @q.list_grants( :permission => :receive )
      # This should fail until the issue is resolved.
      assert_equal 1, grants.size, "Apparently http://developer.amazonwebservices.com/connect/thread.jspa?threadID=15798 is still unresolved"
      assert_kind_of SQS::Grant, grants.first
      assert_equal SQStest.other_aws_account[:display_name], grants.first.display_name

      # There should be one with my email address
      grants = @q.list_grants( :email => SQStest.my_aws_account[:email] )
      assert_equal 1, grants.size
      assert_kind_of SQS::Grant, grants.first
      assert_equal SQStest.other_aws_account[:display_name], grants.first.display_name

      # There should be one with the other email address
      grants = @q.list_grants( :email => SQStest.other_aws_account[:email] )
      # This should fail until the issue is resolved.
      assert_equal 1, grants.size, "Apparently http://developer.amazonwebservices.com/connect/thread.jspa?threadID=15798 is still unresolved"
      assert_kind_of SQS::Grant, grants.first
      assert_equal SQStest.other_aws_account[:display_name], grants.first.display_name
    end

    def test_list_grants
      assert_respond_to @q, :list_grants
      grant = @q.list_grants
      assert_equal 1, grant.size
      grant = grant.first
      assert_equal SQS.permissions[:full], grant.permission
      assert_equal nil, grant.email
      assert_equal SQStest.my_aws_account[:display_name], grant.display_name

      @q.add_grant( :email => SQStest.other_aws_account[:email], :permission => :receive)

      grants = @q.list_grants
      if grants.size != 2
        assert_statistically( :of => 4, :after => lambda{ |i,s| sleep( i * 0.25 ) } ) do
          grants = @q.list_grants
          2 == grants.size
        end
      else
        assert true
      end

      grants.each do |grant|
        case grant.display_name
        when SQStest.my_aws_account[:display_name]
          assert_equal SQS.permissions[:full], grant.permission
        when SQStest.other_aws_account[:display_name]
          assert_equal SQS.permissions[:receive], grant.permission
        else
          flunk "'#{grant.display_name}' is an unknown display name"
        end
      end
    end

    def test_each_message
      assert_respond_to @q, :each_message
      1.upto( 10 ) do |i|
        @q.send_message( "message #{i}" )
      end
      
      i = 0
      @q.each_message do |m|
        i += 1
        assert_equal SQS::Message, m.class
        m.delete
      end
      assert_equal 10, i
    end


    def test_each_grant
      assert_respond_to @q, :each_grant
      @q.add_grant( :email => SQStest.other_aws_account[:email], :permission => :receive)
      @q.each_grant do |g|
        assert_kind_of SQS::Grant, g
      end
    end


    def test_get_visiblity_timeout
      assert_equal SQS::Queue.default_visibility_timeout, @q.visibility_timeout
      assert_kind_of Integer, @q.visibility_timeout

      q = SQS.create_queue :name => "#{@queue_prefix}getvisi", :DefaultVisibilityTimeout => 12345
      assert_equal 12345, q.visibility_timeout
      assert_kind_of Integer, q.visibility_timeout
    end

    def test_set_visiblity_timeout
      assert( @q.visibility_timeout = 456 )
      assert_equal 456, @q.visibility_timeout

      begin
        @q.visibility_timeout = nil
      rescue
        assert_equal 'SQS::EmptyValue', $!.class.name
      else
        flunk 'Was supposed to raise an SQS::EmptyValue'
      end

      assert_nothing_raised do
        @q.visibility_timeout = 0
      end

      begin
        @q.visibility_timeout = -1
      rescue
        assert_equal 'SQS::InvalidAttributeValue', $!.class.name
      else
        flunk 'Was supposed to raise an SQS::InvalidAttributeValue'
      end

      begin
        @q.visibility_timeout = 86401
      rescue
        assert_equal 'SQS::InvalidAttributeValue', $!.class.name
      else
        flunk 'Was supposed to raise an SQS::InvalidAttributeValue'
      end

      begin
        @q.visibility_timeout = Object
      rescue
        assert_equal 'SQS::InvalidAttributeValue', $!.class.name
      else
        flunk 'Was supposed to raise an SQS::InvalidAttributeValue'
      end
    end
    
    
    def test_legal_names
      assert !SQS.create_queue( '' )
      begin
        SQS.create_queue( '81characterslongxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx' )
      rescue
        assert_equal 'SQS::InvalidParameterValue', $!.class.name
      else
        flunk 'Was supposed to raise an SQS::InvalidParameterValue'
      end
      assert q = SQS.create_queue( '80characterslongxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx' )
      q.delete
      
      acceptable_names = [ '-', '_', '0', 's' ]
      acceptable_names.each do |name|
        assert q = SQS.create_queue( name )
        q.delete
      end
    end

  end

  def test_default_visibility_timeout
    assert_respond_to SQS::Queue, :default_visibility_timeout
    assert_equal 30, SQS::Queue.default_visibility_timeout
  end
  
  

  def test_new
    assert_nothing_raised do
      q1 = SQS::Queue.new( :url => 'http://www.slappy.com/', :a => 'a', 'b' => :b )
    end
    q1 = SQS::Queue.new( :url => 'http://www.slappy.com/', :a => 'a', 'b' => :b )
    assert_equal 'http://www.slappy.com/', q1.url
    assert_equal( {}, q1.attributes )

    q2 = SQS::Queue.new 'http://www.slappy.com/'
    assert_equal 'http://www.slappy.com/', q2.url
    assert_equal( {}, q2.attributes )

    assert_raises NameError do
      q.a
    end
    assert_raises NameError do
      q.b
    end

    assert_raises URI::InvalidURIError do
      q = SQS::Queue.new :url => 'http://www.slappy.com'
      q = SQS::Queue.new :url => 'LKJSDFLKJ@#$)()'
    end
  end

  def test_url
    q = SQS::Queue.new :url => 'http://queue.amazonaws.com/A3ZVJ8HH1F466/test96570'
    assert_equal 'http://queue.amazonaws.com/A3ZVJ8HH1F466/test96570', q.url
  end

  def test_name
    q = SQS::Queue.new :url => 'http://queue.amazonaws.com/A3ZVJ8HH1F466/test96570'
    assert_equal 'test96570', q.name
  end

  def test_equality_check
    q1 = SQS::Queue.new :url => 'http://queue.amazonaws.com/A3ZVJ8HH1F466/test96570'
    q2 = SQS::Queue.new :url => 'http://queue.amazonaws.com/A3ZVJ8HH1F466/test96570'
    q3 = SQS::Queue.new :url => 'http://queue.amazonaws.com/A3ZVJ8HH1F466/est96570'

    assert q1 == q2
    assert q1 != q3
    assert q2 != q3
  end
end

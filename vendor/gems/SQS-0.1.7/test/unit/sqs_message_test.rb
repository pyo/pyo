#!/usr/local/bin/ruby
dir = File.expand_path( File::dirname( __FILE__ ) )

require 'test/unit'
require "#{File.expand_path( File.dirname( __FILE__ ) )}/test_setup"


class Test::Unit::TestCase
  def multi_assert( o={}, &b )
    echo "I'm in multi_assert"
    return true
  end
end


class SQS_MessageTest < Test::Unit::TestCase
  def setup
    @used_prefixes ||= {}

    @queue_prefix = "testMSG#{rand( 10040932 )}"
    @queue_prefix = "testMSG#{rand( 10040932 )}" while @used_prefixes[@queue_prefix]

    @used_prefixes[@queue_prefix] = true

    @q = SQS.create_queue( @queue_prefix ) unless SQStest.skip_live_tests?
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
      m = @q.send_message( 'This is something special' )
      assert m.is_a?( SQS::Message )
      assert_equal @q, m.queue
      assert m.delete
      sleep 2
      begin
        m.peek
      rescue
        assert_equal 'SQS::MessageNotFound', $!.class.name
      else
        flunk "Was supposed to raise an SQS::MessageNotFound"
      end

      m.id = nil
      assert_raises SQS::MissingId do
        m.delete
      end
      
      m.queue = nil
      assert_raises SQS::UnavailableQueue do
        m.delete
      end
    end

    def test_peek
      m = @q.send_message( 'This is something else special' )
      assert m.peek
      assert_equal 'This is something else special', m.body


      m.id = nil
      assert_raises SQS::MissingId do
        m.delete
      end
      
      m.queue = nil
      assert_raises SQS::UnavailableQueue do
        m.delete
      end
    end

    def test_body
      m = SQS::Message.new()
      m.body = 'bob'
      assert_equal 'bob', m.body

      m = @q.send_message( 'This is something else really special' )
      assert_equal 'This is something else really special', m.body
    end
  end
  
  def test_new
    assert_nothing_raised do
      SQS::Message.new
    end
    assert_nothing_raised do
      SQS::Message.new :a => 'b'
    end
    assert_nothing_raised do
      SQS::Message.new :a => 'b', :body => ''
    end

    assert_nothing_raised do
      SQS::Message.new :a => 'b', :body => 'This is a test'
    end

    assert_nothing_raised do
      SQS::Message.new 'This is a test'
    end

    m1 = SQS::Message.new :a => 'b', :body => 'This is a test'
    assert m1.is_a?( SQS::Message )

    m2 = SQS::Message.new 'This is a test'
    assert m2.is_a?( SQS::Message )
  end

  def test_id
    m1 = SQS::Message.new 'Message 1'
    m2 = SQS::Message.new :id => 'Message 2'
    m3 = SQS::Message.new :id => 'Message 3', :something => 'else'
    
    assert_equal 'Message 1', m1.id
    assert_equal 'Message 2', m2.id
    assert_equal 'Message 3', m3.id
  end
  
  
#  def test_it_all
#    puts methods.sort.join("\n")
#    tenaciously_assert( :min => 1, :of => 10 ) do
#      
#    end
#  end
end

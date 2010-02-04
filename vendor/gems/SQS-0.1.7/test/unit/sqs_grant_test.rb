#!/usr/local/bin/ruby
dir = File.expand_path( File.dirname( __FILE__ ) )

require 'test/unit'
require "#{File.expand_path( File.dirname( __FILE__ ) )}/test_setup"

class SQS_GrantTest < Test::Unit::TestCase
  def setup
    @used_prefixes ||= {}

    @queue_prefix = "testGRANTEE#{rand( 10040932 )}"
    @queue_prefix = "testGRANTEE#{rand( 10040932 )}" while @used_prefixes[@queue_prefix]

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

  end


  def test_initialize
    g = SQS::Grant.new( :email => 'a@b.c', :id => '123456', :display_name => 'abc', :permission => 'zyx' )
    assert_equal 'abc', g.display_name
    assert_equal '123456', g.id
    assert_equal 'a@b.c', g.email
    assert_equal 'zyx', g.permission
    
    g = SQS::Grant.new( 'iloveemail' )
    assert_equal 'iloveemail', g.email
    assert g.id.nil?
    assert g.display_name.nil?
    assert g.permission.nil?
  end
  
  def test_permission
    g = SQS::Grant.new
    assert_equal nil, g.permission

    g.permission = :full
    assert_equal 'FULLCONTROL', g.permission
    g.permission = :receive
    assert_equal 'RECEIVEMESSAGE', g.permission
    g.permission = :send
    assert_equal 'SENDMESSAGE', g.permission

    g.permission = 'fullcontrol'
    assert_equal 'FULLCONTROL', g.permission
    g.permission = 'receivemessage'
    assert_equal 'RECEIVEMESSAGE', g.permission
    g.permission = 'sendmessage'
    assert_equal 'SENDMESSAGE', g.permission

    g.permission = 'full'
    assert_equal 'FULLCONTROL', g.permission
    g.permission = 'receive'
    assert_equal 'RECEIVEMESSAGE', g.permission
    g.permission = 'send'
    assert_equal 'SENDMESSAGE', g.permission

    g.permission = 'somethingelse'
    assert_equal 'SOMETHINGELSE', g.permission
  end
end



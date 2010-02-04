#!/usr/local/bin/ruby

dir = File.expand_path( File::dirname( __FILE__ ) )
require "#{dir}/../../lib/sqs.rb"

#############################
# Change these settings
class SQStest
  def self.skip_live_tests? ; false ; end
  def self.print_counter? ; false ; end
  def self.my_aws_account ; { :email => 'Replace this with your AWS account email address', :display_name => 'Replace this with your AWS display name' } ; end
  def self.other_aws_account ; { :email => 'Replace this with another valid AWS account email address', :display_name => 'Replace this with another valid AWS display name' } ; end
end

# Uncomment these lines to set up your access_key_id and secret_access_key (not the preferred method)
# SQS.access_key_id = ''
# SQS.secret_access_key = ''

# Uncomment this line to point SQS to a YAML file containing your
# access_key_id and secret_access_key (the preferred method)
SQS.conf_file = "~/aws.yml"

# End change these settings
#############################

good = Hash.new
good[:my_aws_email] = SQStest.my_aws_account[:email] != 'Replace this with your AWS account email address'
good[:my_aws_display_name] = SQStest.my_aws_account[:display_name] != 'Replace this with your AWS display name'
good[:other_aws_email] = SQStest.other_aws_account[:email] != 'Replace this with another valid AWS account email address'
good[:other_aws_display_name] = SQStest.other_aws_account[:display_name] != 'Replace this with another valid AWS display name'

message = good.reject{ |k,v| v }.keys.collect{ |k| k.to_s.gsub( /_/, ' ' ) }.join(", ")


unless message.to_s.empty?
  puts "\nWHOOPS: In order to run these tests, please change the #{ message.index(',') ? 'values' : 'value' } of #{message} in #{File.expand_path( __FILE__ )}\n\n"
  exit
end

puts "\nREMINDERS:
  * You are #{SQStest.skip_live_tests? ? 'skipping' : 'performing'} live tests.
  * You are #{SQStest.print_counter? ? 'printing' : 'not printing'} the counter after each test.
  * #{SQStest.my_aws_account[:email]} is the main email.
  * #{SQStest.other_aws_account[:email]} is the secondary email.
  
You can change all these settings in #{File.expand_path( __FILE__ )}\n\n"

SQS.reset_counter

class Symbol
  def <=>( other )
    return self.to_s <=> other.to_s
  end
end

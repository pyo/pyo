#!/usr/local/bin/ruby
dir = File.expand_path( File.dirname( __FILE__ ) )

Dir[File.join( File.join( File.dirname( __FILE__ ), 'unit' ), "*_test.rb" )].each { |f| require f }

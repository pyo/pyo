require File.join(File.dirname(__FILE__), 'helper')

class CovalenceTest < Test::Unit::TestCase
  context "Default" do
    setup do
      puts "FOO"
    end
  
    should "DO Foo" do
      assert false
    end
  end
end
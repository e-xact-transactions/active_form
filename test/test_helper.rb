require 'rubygems'
require 'minitest/autorun'
require 'byebug'

plugin_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
require File.join(plugin_root, 'lib/active_form')

class MiniTest::Test

  def assert_nothing_raised
    begin
      yield
    rescue
      flunk "Unexpected exception raised: #{$!.message}"
    end
  end
    
end

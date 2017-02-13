ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all
  require "minitest/reporters"
  Minitest::Reporters.use!
  # Add more helper methods to be used by all tests here...
  def set_limits(api_key,string)
      gdbm = GDBM.new("tmp/limits.db")
      gdbm[api_key] = string
      gdbm.close
  end

end

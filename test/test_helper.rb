ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require "minitest/rails"
require 'capybara/rails'
require 'simplecov'
require 'coveralls'
# require 'webmock/minitest'
require "minitest/pride"

require 'minitest/reporters'
Minitest::Reporters.use!(
  Minitest::Reporters::DefaultReporter.new,
  ENV,
  Minitest.backtrace_filter
)



class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...
end


class FunctionalTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    sign_in users(:reviewer)
  end

  teardown do
  	sign_out users(:reviewer)
  end
end

# Inherits from ActionDispatch::IntegrationTest so it gets a few goodies like path helpers
class CapybaraTest <  ActionDispatch::IntegrationTest
  include Capybara::DSL
  include Warden::Test::Helpers
  Warden.test_mode!


  setup do
    Capybara.current_driver = :selenium
    @user = users(:dashboard)
    login_as @user
  end

  teardown do
    logout
    Warden.test_reset!
  end

end


WebMock.allow_net_connect!

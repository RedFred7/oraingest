ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require "minitest/rails"
require 'capybara/rails'
require 'simplecov'
require 'coveralls'
# require 'webmock/minitest'
require "minitest/pride"
require "lib/data_generator"

require 'minitest/reporters'
Minitest::Reporters.use!(
  Minitest::Reporters::SpecReporter.new,
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


class UnitTest < ActiveSupport::TestCase
  include DataGenerator

  NO_OF_TEST_DATA_ITEMS = 6
  setup do
    delete_solr_test_data and create_solr_test_data(NO_OF_TEST_DATA_ITEMS)

  end

  teardown do
    delete_solr_test_data
  end
end



class FunctionalTest < ActionController::TestCase
  include Devise::TestHelpers

  Filter = Struct.new(:facet, :value, :predicate)

  NO_OF_TEST_DATA_ITEMS = 6
  setup do
    sign_in users(:reviewer)
    delete_solr_test_data and create_solr_test_data(NO_OF_TEST_DATA_ITEMS)

  end

  teardown do
    sign_out users(:reviewer)
    delete_solr_test_data
  end
end

# Inherits from ActionDispatch::IntegrationTest so it gets a few goodies like path helpers
class CapybaraTest <  ActionDispatch::IntegrationTest
  include Capybara::DSL
  include Warden::Test::Helpers
  Warden.test_mode!

  # Capybara.server_port = 3001

  NO_OF_TEST_DATA_ITEMS = 4

  setup do
    # Capybara.current_driver = :rack_test
    Capybara.current_driver = :selenium
    @user = users(:dashboard)
    delete_solr_test_data and create_solr_test_data(NO_OF_TEST_DATA_ITEMS)
    login_as @user
  end

  teardown do
    logout
    delete_solr_test_data
    Warden.test_reset!
  end

end


WebMock.allow_net_connect!

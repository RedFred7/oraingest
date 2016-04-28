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

WebMock.allow_net_connect!

class ActiveSupport::TestCase
  include DataGenerator

  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  delete_solr_test_data and create_solr_test_data

  MiniTest::Unit.after_tests {delete_solr_test_data}

  # Add more helper methods to be used by all tests here...
end


class DecoratorUnitTest < ActiveSupport::TestCase

  setup do
    @doc = SolrDoc.find_by_attrib(:status, Sufia.config.submitted_status).first    
    ## FIXME: doc should already be a SolrDoc but, for some reason,
    # it comes out as a Hash so need to expicitly convert it to SolrDoc
    # for now, until I understand why this happens
    # @doc = SolrDoc.new(doc)
    @decorated_doc = SolrDocPresenter.new(@doc)

    @doc.date_published = "2014"
  end

end



class FunctionalTest < ActionController::TestCase
  include Devise::TestHelpers

  Filter = Struct.new(:facet, :value, :predicate)

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

  # Capybara.server_port = 3001
  delete_solr_test_data and create_solr_test_data

  MiniTest::Unit.after_tests {delete_solr_test_data}  

  setup do
    # Capybara.current_driver = :rack_test
    Capybara.current_driver = :selenium
    @user = users(:dashboard)
    login_as @user
  end

  teardown do
    logout
    Warden.test_reset!
  end

end

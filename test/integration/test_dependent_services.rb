require "test/unit"
require_relative '../test_helper'
require "net/http"
require 'open3'


class TestDependentServices < Test::Unit::TestCase

  def setup

    case Rails.env
    when "development"
      @port = 8080
    when "test"
      @port = ENV['SOLR_PORT']
    end
  end

  def test_java_is_installed
    stdin, stdout, stderr = Open3.popen3('java -version')
    refute(stderr.read.empty?)
  end

  def test_apache_is_running
    stdin, stdout, stderr = Open3.popen3('sudo service apache2 status')
    assert_not_nil(stdout.read.match /apache2 is running/)
  end

  def test_tomcat_is_running
    stdin, stdout, stderr = Open3.popen3('sudo service tomcat7 status')
    assert_not_nil(stdout.read.match /Tomcat servlet engine is running/)
  end  

  def test_solr_is_running
    assert_not_nil(@port, "ENV['SOLR_PORT'] expected to be not nil!")
    uri = URI.parse("http://127.0.0.1:#{@port}/solr/#/#{Rails.env}")
    res = Net::HTTP.get_response(uri)
    assert(res.is_a? Net::HTTPOK)
  end



  def teardown
  end
end
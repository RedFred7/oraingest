require 'test_helper'
require 'faker'

class SolrDocPresenterTest < DecoratorUnitTest

  test "should set date_type when published and accepted dates exist" do
    # test doc has values for published and accepted dates
    assert_equal "published", @decorated_doc.date_type
  end

  test "should set date_type when only published date exists" do
    test_doc = Marshal.load(Marshal.dump(@doc))
    test_doc.date_accepted = ""
    decorated_doc = SolrDocPresenter.new(test_doc)
    assert_equal "published", decorated_doc.date_type
  end

  test "should set date_type when only accepted date exists" do
    test_doc = Marshal.load(Marshal.dump(@doc))
    test_doc.date_published = ""
    decorated_doc = SolrDocPresenter.new(test_doc)
    assert_equal "accepted", decorated_doc.date_type
  end

  test "should set date_type when both dates are empty" do
    test_doc = Marshal.load(Marshal.dump(@doc))
    test_doc.date_published = ""
    test_doc.date_accepted = ""
    decorated_doc = SolrDocPresenter.new(test_doc)
    assert_equal "", decorated_doc.date_type
  end  

  test "should set date_type when both dates are nil" do
    test_doc = Marshal.load(Marshal.dump(@doc))
    test_doc.date_published = nil
    test_doc.date_accepted = nil
    decorated_doc = SolrDocPresenter.new(test_doc)
    assert_equal "", decorated_doc.date_type
  end  


  test "should set tickets" do
    # no RT tickets in test data
    assert_equal @doc.rt_tickets, @decorated_doc.tickets
  end

  test "should set un-trimmed title" do
    # @doc's title is less than 300 chars long
    assert_equal @doc.title, @decorated_doc.trim_title
  end


  test "should set un-trimmed abstract" do
    # @doc's abstract is less than 300 chars long
    assert_equal @doc.abstract, @decorated_doc.trim_abstract
  end

  test "should set trimmed title" do
    # create doc with title over 300 chars long
    long_doc = Marshal.load(Marshal.dump(@doc))
    long_doc.title = Faker::Lorem.characters(310)
    decorated_long_doc = SolrDocPresenter.new(long_doc)

    test_value = decorated_long_doc.trim_title
    refute_equal long_doc.title, test_value
    assert_equal 300, test_value.size
    assert_equal "...", test_value.slice(-3, 3)
  end

  test "should set trimmed abstract" do
    # create doc with abstract over 300 chars long
    long_doc = Marshal.load(Marshal.dump(@doc))
    long_doc.abstract = Faker::Lorem.characters(310)
    decorated_long_doc = SolrDocPresenter.new(long_doc)

    test_value = decorated_long_doc.trim_abstract
    refute_equal long_doc.abstract, test_value
    assert_equal 300, test_value.size
    assert_equal "...", test_value.slice(-3, 3)
  end

  test "should set date when only date_published exists" do
    #should return date_published value, since it exists in test doc
    test_doc = Marshal.load(Marshal.dump(@doc))
    test_doc.date_accepted = ""
    decorated_doc = SolrDocPresenter.new(test_doc)
    assert_equal "2014", decorated_doc.date
  end

  test "should set date when only date_accepted exists" do
    # create doc with only date_accepted
    long_doc = Marshal.load(Marshal.dump(@doc))
    long_doc.date_published = ""
    decorated_long_doc = SolrDocPresenter.new(long_doc)

    assert_equal "10/03/2015", decorated_long_doc.date
  end


  test "should set date when no dates exist" do
    # create doc with nil dates
    long_doc = Marshal.load(Marshal.dump(@doc))
    long_doc.date_published = nil
    long_doc.date_accepted = nil
    decorated_long_doc = SolrDocPresenter.new(long_doc)

    assert_equal "", decorated_long_doc.date
  end

  test "should set date when all dates are empty" do
    # create doc with empty dates
    long_doc = Marshal.load(Marshal.dump(@doc))
    long_doc.date_published = ""
    long_doc.date_accepted = ""
    decorated_long_doc = SolrDocPresenter.new(long_doc)

    assert_equal "", decorated_long_doc.date
  end


end

require "test_helper"
require "lib/data_generator"


class ReviewingControllerTest < FunctionalTest
  extend DataGenerator


  NO_OF_TEST_DATA_ITEMS = 3
  delete_solr_test_data and create_solr_test_data(NO_OF_TEST_DATA_ITEMS)

  MiniTest::Unit.after_tests {delete_solr_test_data}


  test "GET index responds with :success for reviewer" do
    get :index
    assert_response :success
  end

  test "GET index responds with :error for non-reviewer" do
    sign_out users(:reviewer)
    sign_in users(:non_reviewer)
    assert_raises(CanCan::AccessDenied){get :index}
    sign_out users(:non_reviewer)
  end

  test "initial filter is set to get all claimed items for current reviewer" do
    get :index

    assert_equal 2, session[:review_dash_filters].size
    filter_1, filter_2 = session[:review_dash_filters][0],  session[:review_dash_filters][1]
    assert_equal :STATUS, filter_1.facet
    assert_equal :Claimed, filter_1.value
    assert_equal :CURRENT_REVIEWER, filter_2.facet
    assert_equal 'reviewer1@example.com', filter_2.value
  end


  test "it gets all unclaimed items" do
    filter = [{facet: "STATUS",predicate: "NOT",value: "Claimed"}]
    get :index, {apply_filter: filter}
    assert_equal  NO_OF_TEST_DATA_ITEMS, assigns[:docs_found]
  end

  test "an item is claimed" do
  	item_to_claim = ReviewingControllerTest.test_data[1]

    if ReviewingControllerTest.claim_an_item( item_to_claim, @controller.current_user )
      filter = [{facet: "STATUS",value: "Claimed"},{facet: "CURRENT_REVIEWER",value: "#{@controller.current_user}"}]

      get :index, {apply_filter: filter}
      assert_equal 1, assigns[:docs_found]

    else
      flunk "Failed to claim an item!"
    end
  end

end

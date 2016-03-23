require "test_helper"
require "lib/data_generator"


class ReviewDashboardTest < CapybaraTest
  extend DataGenerator

  SimpleCov.command_name "test:integration"

  NO_OF_TEST_DATA_ITEMS = 3
  delete_solr_test_data and create_solr_test_data(NO_OF_TEST_DATA_ITEMS)

  MiniTest::Unit.after_tests {delete_solr_test_data}


  test "reviewer can access review dashboard" do
    visit '/dash'
    click_link('Show all items')
    assert_equal page.has_text?("#{@user.email} Dashboard"), true
    assert_equal page.has_text?("3 Items found"), true
  end


  test "reviewer can claim a draft item" do
    visit '/dash'
    title_to_claim = ReviewDashboardTest.test_data[0]['desc_metadata__title_tesim'].first
    fill_in('dash_search', :with => title_to_claim.gsub(/\s/, '+'))
    click_button('dash_submit')
    assert_equal page.has_text?("1 Items found"), true
    click_link('claim_item_btn')
    assert_equal page.has_selector?('span.tag.tag-claimed'), true
    assert_equal page.has_selector?('a#unclaim_item_btn'), true
  end












end

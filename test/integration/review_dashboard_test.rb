require "test_helper"


class ReviewDashboardTest < CapybaraTest
  include DataGenerator

  SimpleCov.command_name "test:integration"

  test "reviewer can access review dashboard" do
    visit '/dash'
    click_link('Show all items')
    assert_equal page.has_text?("#{@user.email} Dashboard"), true
    assert_equal page.has_text?("#{NO_OF_TEST_DATA_ITEMS} Items found"), true
  end

 test 'reviewer can see all unclaimed items' do
    visit '/dash'
    click_link("Show all items")
    click_link("All unclaimed items")
    assert_equal page.has_text?("#{NO_OF_TEST_DATA_ITEMS-1} Items found"), true
    end  


  test "reviewer can claim a draft item" do
    visit '/dash'
    title_to_claim = get_test_data_with_status(Sufia.config.submitted_status).first.title
    fill_in('dash_search', :with => title_to_claim.gsub(/\s/, '+'))
    click_button('dash_submit')
    assert_equal page.has_text?("1 Items found"), true
    click_link('claim_item_btn')
    assert_equal page.has_selector?('span.tag.tag-claimed'), true
    assert_equal page.has_selector?('a#unclaim_item_btn'), true
  end


  test "reviewer cannot claim an assigned item" do
    # visit '/dash'
    # title_to_claim = @test_data.first["desc_metadata__title_tesim"].first
    # fill_in('dash_search', :with => title_to_claim.gsub(/\s/, '+'))
    # click_button('dash_submit')
    # assert_equal page.has_text?("1 Items found"), true
    # click_link('claim_item_btn')
    # assert_equal page.has_selector?('span.tag.tag-claimed'), true
    # assert_equal page.has_selector?('a#unclaim_item_btn'), true
  end



  test 'reviewer can unclaim a claimed item' do
    visit '/dash'
    click_link("Show all items")
    click_link("All claimed by #{@user.email}")
    assert_equal page.has_text?("1 Items found"), true
    assert_equal page.has_selector?('a#unclaim_item_btn'), true
    click_link('unclaim_item_btn')
    assert page.has_text?("No Items retrieved for these search criteria.")
  end


end

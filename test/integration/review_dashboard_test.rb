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
    ## unclaimed items are items not claimed and not draft
    assert_equal page.has_text?("5 Items found"), true
  end


  test "reviewer can claim a submitted item" do
    visit '/dash'

    submitted_item = generate_test_item(:thesis, Sufia.config.submitted_status)
    title_to_claim = submitted_item.title

    fill_in('dash_search', :with => title_to_claim.gsub(/\s/, '+'))
    click_button('dash_submit')
    assert_equal page.has_text?("1 Items found"), true
    click_link('claim_item_btn')
    assert_equal page.has_selector?('span.tag.tag-claimed'), true
    assert_equal page.has_selector?('a#unclaim_item_btn'), true

    remove_test_item(:thesis, submitted_item.id)
  end


  test "reviewer cannot claim a draft item" do
    visit '/dash'
    title_to_claim = SolrDoc.find_by_attrib(:status, Sufia.config.draft_status).first.title
    fill_in('dash_search', :with => title_to_claim.gsub(/\s/, '+'))
    click_button('dash_submit')
    assert_equal page.has_text?("1 Items found"), true
    refute_equal page.has_selector?('claim_item_btn'), true
  end



  test 'reviewer can unclaim a claimed item' do
    visit '/dash'
    title_to_claim = SolrDoc.find_by_attrib(:status, Sufia.config.claimed_status).first.title

    claimed_item = generate_test_item(:thesis, Sufia.config.claimed_status)
    title_to_unclaim = claimed_item.title

    fill_in('dash_search', :with => title_to_unclaim.gsub(/\s/, '+'))
    click_button('dash_submit')
    assert_equal page.has_text?("1 Items found"), true
    assert_equal page.has_selector?('a#unclaim_item_btn'), true
    click_link('unclaim_item_btn')
    assert page.has_text?("No Items found.")
  end


end

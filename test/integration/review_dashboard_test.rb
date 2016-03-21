require "test_helper"


class CapybaraTest

  SimpleCov.command_name "test:integration"


  create_solr_test_data

  MiniTest::Unit.after_tests {delete_solr_test_data}


  test "reviewer can access review dashboard" do
    visit '/dash'
    click_link('Show all items')
    assert_equal page.has_text?("#{@user.email} Dashboard"), true
    assert_equal page.has_text?("3 Items found"), true
  end


  test "reviewer can claim a draft item" do
  	visit '/dash'
  	fill_in('dash_search', :with => 'Elton+Archive+Arctic+expedition') 
  	click_button('dash_submit')
    assert_equal page.has_text?("1 Items found"), true
    click_link('claim_item_btn')
    assert_equal page.has_selector?('span.tag.tag-claimed'), true
    assert_equal page.has_selector?('a#unclaim_item_btn'), true
  end




  # test "non-reviewers can't access review dashboard" do
  #   non_reviewing_user = users(:non_reviewer)
  #   login_as non_reviewing_user
  #   visit '/dash'
  #   assert_equal page.has_text?("You do not have permission to review submissions"), true
  #   # assert_raises(CanCan::AccessDenied){visit '/dash'}
  #   logout
  # end










end

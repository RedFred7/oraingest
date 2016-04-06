require 'test_helper'

class SolrDocPresenterTest < UnitTest

  test "should give description with correct attributes" do
    doc = get_test_data_with_status(Sufia.config.submitted_status).first
    decorated_doc = SolrDocPresenter.new(doc)
    assert_equal "this is my presenter", decorated_doc.description
  end

end

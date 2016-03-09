require "test_helper"

class ReviewDashboardTest < CapybaraIntegrationTest
  include Warden::Test::Helpers
  Warden.test_mode!

  setup do
    Capybara.use_default_driver       
    login_as users(:reviewer)
  end

  teardown do
    Warden.test_reset!
  end

  # test "archivist can't access review dashboard" do
  #   Capybara.default_driver = :selenium
  #   login_as users(:archivist)
  #   visit '/dash'
  #   assert page.has_content?("You do not have permission to review submissions")
  #   # logout

  # end
  test "fred" do 
    puts users(:reviewer).display_name
  end

  test "doit" do 
    Article.create do |a|
        params = {'worktype'  =>  {'typeLabel'  =>  'Journal article'}, 'title'  =>  'test.docx', 'subtitle'  =>  '', 'abstract'  =>  '', 'publication'  =>  {'publicationStatus'  =>  '', 'reviewStatus'  =>  '', 'publisher_attributes'  =>  {'0'  =>  {'agent_attributes'  =>  {'0'  =>  {'name'  =>  '', 'website'  =>  ''}}}}, 'dateAccepted'  =>  '', 'datePublished'  =>  '', 'location'  =>  '', 'hasDocument_attributes'  =>  {'0'  =>  {'doi'  =>  '', 'uri'  =>  '', 'identifier'  =>  '', 'series_attributes'  =>  {'0'  =>  {'title'  =>  ''}}, 'journal_attributes'  =>  {'0'  =>  {'title'  =>  '', 'issn'  =>  '', 'eissn'  =>  '', 'volume'  =>  '', 'issue'  =>  '', 'pages'  =>  ''}}}}}, 'subject'  =>  {'0'  =>  {'subjectLabel'  =>  '', 'subjectAuthority'  =>  '', 'subjectScheme'  =>  ''}}, 'keyword'  =>  [''], 'language'  =>  {'languageLabel'  =>  '', 'languageCode'  =>  '', 'languageAuthority'  =>  '', 'languageScheme'  =>  ''}, 'creation'  =>  {'creator_attributes'  =>  {'0'  =>  {'name'  =>  'Test Two', 'email'  =>  '', 'sameAs'  =>  '', 'role'  =>  ['http://vocab.ox.ac.uk/ora#author'], 'affiliation'  =>  {'name'  =>  '', 'sameAs'  =>  ''}}}}, 'qualifiedRelation'  =>  {'0'  =>  {'entity_attributes'  =>  {'0'  =>  {'title'  =>  '', 'description'  =>  '', 'identifier'  =>  '', 'citation'  =>  ''}}, 'relation'  =>  ''}}, 'oaStatus'  =>  '', 'oaReason'  =>  '', 'refException'  =>  '', 'hasPart'  =>  {'0'  =>  {'type'  =>  'Content', 'identifier'  =>  'content01', 'description'  =>  '', 'accessRights'  =>  {'embargoDate'  =>  {'end'  =>  {'label'  =>  '', 'date'  =>  ''}, 'duration'  =>  {'years'  =>  '', 'months'  =>  ''}, 'start'  =>  {'label'  =>  'Today', 'date'  =>  ''}}, 'embargoRelease'  =>  ''}}}, 'accessRights'  =>  {'embargoStatus'  =>  'Open access', 'embargoDate'  =>  {'end'  =>  {'label'  =>  '', 'date'  =>  ''}, 'duration'  =>  {'years'  =>  '', 'months'  =>  ''}, 'start'  =>  {'label'  =>  'Today', 'date'  =>  ''}}, 'embargoRelease'  =>  ''}, 'funding'  =>  {'funder_attributes'  =>  {'0'  =>  {'agent_attributes'  =>  {'0'  =>  {'name'  =>  ''}}, 'awards_attributes'  =>  {'0'  =>  {'grantNumber'  =>  ''}}, 'funds'  =>  ''}}}, 'license'  =>  {'licenseLabel'  =>  '', 'licenseStatement'  =>  ''}, 'workflows_attributes'  =>  {'0'  =>  {'id'  =>  '_:g70336805082780', 'involves'  =>  '', 'entries_attributes'  =>  {'0'  =>  {'description'  =>  ''}}, 'comments_attributes'  =>  {'0'  =>  {'description'  =>  ''}}}}, 'permissions_attributes'  =>  {'0'  =>  {'type'  =>  'user', 'name'  =>  '', 'access'  =>  ''}}}.with_indifferent_access
      end
  end


  test "reviewer can access review dashboard" do
    Capybara.default_driver = :selenium
    visit '/dash'
    assert page.has_content?("Fred dashboard")

  end

end

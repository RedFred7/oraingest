require 'test_helper'

class SolrDocTest < ActiveSupport::TestCase

  @@HUMAN_FIELDS = [:ID,
                    :STATUS,
                    :TITLE,
                    :TYPE,
                    :ABSTRACT,
                    :DEPOSITOR,
                    :DATE_PUBLISHED,
                    :DATE_ACCEPTED,
                    :CREATOR,
                    :CURRENT_REVIEWER,
                    :RT_TICKETS,
                    :SUBJECT,
                    :MODEL,
                    :CONTRIBUTOR,
                    :KEYWORD,
                    :PUBLISHER]


  @@SOLR_FIELDS = ["id",
                   "MediatedSubmission_status_ssim",
                   "desc_metadata__title_tesim",
                   "desc_metadata__type_tesim",
                   "desc_metadata__abstract_tesim",
                   "depositor_tesim",
                   "desc_metadata__datePublished_tesim",
                   "desc_metadata__dateAccepted_tesim",
                   "desc_metadata__creatorName_tesim",
                   "MediatedSubmission_current_reviewer_id_ssim",
                   "MediatedSubmission_all_email_threads_ssim",
                   "desc_metadata__subject_tesim",
                   "active_fedora_model_ssi",
                   "desc_metadata__contributor_tesim",
                   "desc_metadata__keyword_sim",
                   "desc_metadata__publisher_sim"]

  test "can access Solr attributes" do
    assert_equal  @@HUMAN_FIELDS, Solrium.attributes
  end

  test "can access Solr values" do
    assert_equal  @@SOLR_FIELDS, Solrium.values
  end

  test "can lookup Solr names from readable names" do
    @@HUMAN_FIELDS.each_with_index do |readable_name, idx|
      assert_equal Solrium.lookup(readable_name), @@SOLR_FIELDS[idx]
    end
  end

  test "can lookup readable names (as symbols) from Solr names" do
    @@SOLR_FIELDS.each_with_index do |solr_name, idx|
      assert_equal Solrium.reverse_lookup(solr_name), @@HUMAN_FIELDS[idx].to_s.downcase.to_sym
    end
  end  

  test "can lookup readable names (as strings) from Solr names" do
    @@SOLR_FIELDS.each_with_index do |solr_name, idx|
      assert_equal Solrium.reverse_lookup(solr_name, :string), @@HUMAN_FIELDS[idx].to_s.downcase
    end
  end  


end

module DataGenerator
  require 'faker'

  @@solr_connection ||= RSolr.connect url: Rails.application.config.solr[Rails.env]['url']

  def create_solr_test_data(no_of_items)
    data_file ||= File.open("test/data/solr_doc", "r")
    @solr_doc_template = eval(data_file.read)
    data_file.close
    @test_data = []
    raise TypeError, "'solr_doc_template' isn't a Hash" unless @solr_doc_template.is_a? Hash

    raise ArgumentError, "'no_of_items' must be a number" unless no_of_items.is_a? Fixnum


    # generate test data
    no_of_items.times do
      solr_test_item = @solr_doc_template.clone
      solr_test_item['id'] = "uuid:#{SecureRandom.uuid}"
      solr_test_item['desc_metadata__title_tesim'] =
        Array.new(1, Faker::Lorem.sentence)
      @test_data << solr_test_item

    end

    res = @@solr_connection.add @test_data
    save_to_solr
  end

  def delete_solr_test_data
    res = @@solr_connection.delete_by_query '*:*'
    save_to_solr
  end

  def test_data
    @test_data
  end

  def claim_an_item(item, user)
    item = @solr_doc_template.clone
    item['id'] = "uuid:#{SecureRandom.uuid}"
    item['desc_metadata__title_tesim'] = Array.new(1, Faker::Lorem.sentence)
    item["MediatedSubmission_all_reviewer_ids_ssim"].push user.email
    item["MediatedSubmission_current_reviewer_id_ssim"] = Array.new(1, user.email)
    item["MediatedSubmission_status_ssim"].push Sufia.config.claimed_status
    res = @@solr_connection.add item
    save_to_solr

  end

  private

  def save_to_solr
    res = @@solr_connection.commit
    res['responseHeader']['status'] == 0
  end
end

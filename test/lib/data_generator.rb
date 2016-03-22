module DataGenerator

  @@solr_connection ||= RSolr.connect url: Rails.application.config.solr[Rails.env]['url']  

  def create_solr_test_data
    data_file ||= File.open("test/data/solr_doc", "rb")
    solr_test_data_1 = eval(data_file.read)
    data_file.close
    raise TypeError, "solr_test_data_1 isn't a Hash" unless solr_test_data_1.is_a? Hash

    solr_test_data_2, solr_test_data_3 = solr_test_data_1.clone, solr_test_data_1.clone

    solr_test_data_2['id'] = SecureRandom.uuid
    solr_test_data_2['desc_metadata__title_tesim'] =
      Array.new(1, 'The Real Slim Shady')
    solr_test_data_3['id'] = SecureRandom.uuid
    solr_test_data_3['desc_metadata__title_tesim'] =
      Array.new(1, 'Hasta la Vista baby')

    res = @@solr_connection.add [solr_test_data_1, solr_test_data_2, solr_test_data_3]
    res = @@solr_connection.commit
    res['responseHeader']['status'] == 0
  end

  def delete_solr_test_data
    res = @@solr_connection.delete_by_query '*:*'
    res = @@solr_connection.commit
    res['responseHeader']['status'] == 0
  end

end

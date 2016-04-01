module DataGenerator
  require 'faker'


  data_file ||= File.open("test/data/solr_doc", "r")
  SOLR_DOC_TEMPLATE = eval(data_file.read)
  data_file.close

  SOLR_CONNECTION ||= RSolr.connect url: Rails.application.config.solr[Rails.env]['url']


  module ClassMethods
    def claim_an_item(item, user)
      item = Marshal.load(Marshal.dump(SOLR_DOC_TEMPLATE))
      item['id'] = "uuid:#{SecureRandom.uuid}"
      item['desc_metadata__title_tesim'] = Array.new(1, Faker::Lorem.sentence)
      item["MediatedSubmission_all_reviewer_ids_ssim"].push user.email
      item["MediatedSubmission_current_reviewer_id_ssim"] = Array.new(1, user.email)
      item["MediatedSubmission_status_ssim"].push Sufia.config.claimed_status
      res = SOLR_CONNECTION.add(item) and SOLR_CONNECTION.commit
      res['responseHeader']['status'] == 0

    end
  end

  module InstanceMethods


    def create_solr_test_data(no_of_items)

      @test_data = []
      raise TypeError, "'solr_doc_template' isn't a Hash" unless SOLR_DOC_TEMPLATE.is_a? Hash

      raise ArgumentError, "'no_of_items' must be a number" unless no_of_items.is_a? Fixnum


      # generate test data
      (no_of_items-1).times do
        # solr_test_item = Hash.new.replace(SOLR_DOC_TEMPLATE)
        solr_test_item = Marshal.load(Marshal.dump(SOLR_DOC_TEMPLATE))
        solr_test_item['id'] = "uuid:#{SecureRandom.uuid}"
        solr_test_item['desc_metadata__title_tesim'] =
          Array.new(1, Faker::Lorem.sentence)
        @test_data << solr_test_item
      end


      @test_data << generate_claimed_item(@user)


      res = SOLR_CONNECTION.add @test_data
      save_to_solr
    end

    def delete_solr_test_data
      res = SOLR_CONNECTION.delete_by_query '*:*'
      save_to_solr
    end

    def test_data
      @test_data
    end



    private

    def save_to_solr
      res = SOLR_CONNECTION.commit
      res['responseHeader']['status'] == 0
    end



    def generate_claimed_item(current_user)
      solr_test_item = Marshal.load(Marshal.dump(SOLR_DOC_TEMPLATE))
      solr_test_item['id'] = "uuid:#{SecureRandom.uuid}"
      solr_test_item['desc_metadata__title_tesim'] = Array.new(1, Faker::Lorem.sentence)      
      solr_test_item["MediatedSubmission_all_reviewer_ids_ssim"].push "user@example.com", "qa@bodleian.ac.co.uk", current_user
      solr_test_item["MediatedSubmission_current_reviewer_id_ssim"] = Array.new(1, current_user)
      solr_test_item["MediatedSubmission_status_ssim"].push Sufia.config.submitted_status, Sufia.config.claimed_status
      solr_test_item


    end
  end #module


  def self.included(receiver)
    receiver.extend ClassMethods
    receiver.send :include, InstanceMethods
  end

end #module

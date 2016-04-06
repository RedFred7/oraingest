module DataGenerator
  require 'faker'


  data_file ||= File.open("test/data/solr_doc", "r")
  SOLR_DOC_TEMPLATE = eval(data_file.read)
  data_file.close

  SOLR_CONNECTION ||= RSolr.connect url: Rails.application.config.solr[Rails.env]['url']


  module ClassMethods
    def claim_an_item(item, user)
      # make deep copy of SOLR_DOC_TEMPLATE object
      item = Marshal.load(Marshal.dump(SOLR_DOC_TEMPLATE))
      solr_doc = SolrDoc.new(item)
      solr_doc.id = "uuid:#{SecureRandom.uuid}"
      solr_doc.title = Array.new(1, Faker::Lorem.sentence)
      solr_doc.all_reviewers.push user.email
      solr_doc.current_reviewer = Array.new(1, user.email)
      solr_doc.status.push Sufia.config.claimed_status
      res = SOLR_CONNECTION.add(solr_doc.to_hash) and SOLR_CONNECTION.commit
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
        # make deep copy of SOLR_DOC_TEMPLATE object
        solr_test_item = Marshal.load(Marshal.dump(SOLR_DOC_TEMPLATE))
        solr_doc = SolrDoc.new(solr_test_item)
        solr_doc.id = "uuid:#{SecureRandom.uuid}"
        solr_doc.title = Array.new(1, Faker::Lorem.sentence)
        @test_data << solr_doc.to_hash
      end


      @test_data << generate_claimed_item(@user).to_hash


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
      solr_doc = SolrDoc.new(solr_test_item)
      solr_doc.id = "uuid:#{SecureRandom.uuid}"
      solr_doc.title = Array.new(1, Faker::Lorem.sentence)
      solr_doc.all_reviewers.push "user@example.com", "qa@bodleian.ac.co.uk", current_user
      solr_doc.current_reviewer = Array.new(1, current_user)
      solr_doc.status.push Sufia.config.claimed_status
      solr_doc
    end

  end #module


  def self.included(receiver)
    receiver.extend ClassMethods
    receiver.send :include, InstanceMethods
  end

end #module

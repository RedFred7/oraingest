module DataGenerator
  require 'faker'


  SOLR_CONNECTION ||= RSolr.connect url: Rails.application.config.solr[Rails.env]['url']



  module InstanceMethods


    def create_solr_test_data(no_of_items)

      @test_data = []
      raise TypeError, "'solr_doc_template' isn't a Hash" unless SOLR_DOC_ARTICLE.is_a? Hash

      raise ArgumentError, "'no_of_items' must be a number" unless no_of_items.is_a? Fixnum


      # generate test data
      (no_of_items-2).times do
        @test_data << generate_solr_doc
      end

      # add a item with claimed status
      @test_data << generate_solr_doc(reviewer: @user, status: Sufia.config.claimed_status)

      # add a item with assigned status
      @test_data << generate_solr_doc(reviewer: @user, status: Sufia.config.assigned_status)

      res = SOLR_CONNECTION.add @test_data.map(&:to_hash)
      save_to_solr
    end

    def delete_solr_test_data
      res = SOLR_CONNECTION.delete_by_query '*:*'
      save_to_solr
    end

    def get_test_data_with_status(status)
    	@test_data.select {|i| i.last_status == status}
    end

    def get_test_data_without_status(status)
    	@test_data.select {|i| i.last_status != status}
    end    


    private

    def save_to_solr
      res = SOLR_CONNECTION.commit
      res['responseHeader']['status'] == 0
    end


    def generate_solr_doc(**args)
      # make deep copy of SOLR_DOC_ARTICLE object
      solr_test_item = Marshal.load(Marshal.dump(SOLR_DOC_ARTICLE))
      solr_doc = SolrDoc.new(solr_test_item)
      solr_doc.id = "uuid:#{SecureRandom.uuid}"
      solr_doc.title = args[:title] || Array.new(1, Faker::Lorem.sentence)
      if args[:reviewer]
        solr_doc.all_reviewers.push "user@example.com", "qa@bodleian.ac.co.uk", args[:reviewer]
        solr_doc.current_reviewer = Array.new(1, args[:reviewer])
      end
      if args[:status] && (args[:status] == Sufia.config.claimed_status)
        solr_doc.status.push  Sufia.config.claimed_status
      elsif args[:status]
        solr_doc.status.push( args[:status] )
      end
      solr_doc
    end

    def claim_an_item(item, user)
      solr_doc = generate_solr_doc
      solr_doc.all_reviewers.push user.email
      solr_doc.current_reviewer = Array.new(1, user.email)
      solr_doc.status.push Sufia.config.claimed_status
      res = SOLR_CONNECTION.add(solr_doc.to_hash) and SOLR_CONNECTION.commit
      res['responseHeader']['status'] == 0

    end

  end #module


  def self.included(receiver)
    receiver.send :include, InstanceMethods
  end

end #module

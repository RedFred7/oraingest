module DataGenerator
  require 'faker'


  SOLR_CONNECTION ||= RSolr.connect url: Rails.application.config.solr[Rails.env]['url']



  module InstanceMethods


    def create_solr_test_data

      # raise ArgumentError, "'no_of_items' must be a number" unless no_of_items.is_a? Fixnum

      15.times do |i|
        t = Thesis.new(title: Faker::Lorem.sentence)
        t.save

        set_status(t, Sufia.config.draft_status) if i <= 5
        set_status(t, Sufia.config.submitted_status) if (5..9).include? i
        if i > 9
          set_status(t, Sufia.config.claimed_status)
          set_reviewer(t, "reviewer1@example.com")
        end
        t.save

        solr_doc = SolrDoc.find_by_id(t.id)
        solr_doc.type = "Thesis"
        solr_doc.depositor = "test@bodleian.com"
        solr_doc.save
      end
    end

    def delete_solr_test_data
      if SolrDoc.delete_all
        Thesis.delete_all
      else
        raise "failed to delete Solr data"
      end
    end



    private


    def set_status(publication, new_status)
      publication.workflows.first.instance_variable_get(:@target)['entries'].target.first.status.unshift new_status
    end

    def set_reviewer(publication, reviewer_id)
      publication.workflows.first.instance_variable_get(:@target)['entries'].target.first.reviewer_id.unshift reviewer_id
    end

  end #module


  def self.included(receiver)
    receiver.send :include, InstanceMethods
  end

end #module

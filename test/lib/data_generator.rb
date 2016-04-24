module DataGenerator
  require 'faker'


  SOLR_CONNECTION ||= RSolr.connect url: Rails.application.config.solr[Rails.env]['url']


  NO_OF_TEST_DATA_ITEMS = 15
  module InstanceMethods

    def generate_test_item(type, status, reviewer=nil)
      klass = Kernel.const_get(type.to_s.titleize)
      item = klass.new(title: Faker::Lorem.sentence)
      item.save

      solr_doc = SolrDoc.find_by_id(item.id)
      solr_doc.all_reviewers = []
      solr_doc.type = type.to_s.titleize
      solr_doc.status = status
      solr_doc.depositor = "test@bodleian.com"
      solr_doc.date_accepted = "10/03/2015"
      solr_doc.date_published = "2014"
      if reviewer
        solr_doc.current_reviewer = reviewer
        solr_doc.all_reviewers = Array.new(1, reviewer)
      end

      solr_doc.save
      solr_doc
    end

    def remove_test_item(type, id)
      klass = Kernel.const_get(type.to_s.titleize)
      solr_doc = SolrDoc.find_by_id( id )
      if solr_doc.delete
        item = klass.find(id)
        if item 
          res = item.delete 
          res['responseHeader']['status'] == 0
        else
          raise "Trying to delete #{type} item with id: #{id}. Item not found!"
        end
      else
        raise "Unable to delete Solr item with id: #{id}!"
      end
    end

  end #module



  module ClassMethods

    def create_solr_test_data

      # raise ArgumentError, "'no_of_items' must be a number" unless no_of_items.is_a? Fixnum

      NO_OF_TEST_DATA_ITEMS.times do |i|
        t = Thesis.new(title: Faker::Lorem.sentence)
        t.save

        solr_doc = SolrDoc.find_by_id(t.id)
        solr_doc.all_reviewers = []
        solr_doc.type = "Thesis"
        solr_doc.depositor = "test@bodleian.com"
        solr_doc.date_accepted = "10/03/2015"
        solr_doc.date_published = "2014"

        solr_doc.status = Sufia.config.draft_status if i <= 5
        solr_doc.status = Sufia.config.submitted_status if (5..9).include? i        
        if i > 9
          solr_doc.status = Sufia.config.claimed_status
          solr_doc.current_reviewer = "reviewer1@example.com"
          solr_doc.all_reviewers = Array.new(1, "reviewer1@example.com")
        end

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
    receiver.extend ClassMethods
    receiver.send :include, InstanceMethods
  end

end #module


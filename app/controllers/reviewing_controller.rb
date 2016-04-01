
# FIXME: ugly hack to get Solr working with Kaminari
class RSolr::Response::PaginatedDocSet
  attr_reader :limit_value
end



class ReviewingController < ApplicationController

  Filter = Struct.new(:facet, :value, :predicate)
  before_filter :restrict_access_to_reviewers


  def restrict_access_to_reviewers
    unless can? :review, :all
      raise  CanCan::AccessDenied.new("You do not have permission to review submissions.", :review_submissions, current_user)
    end
  end

  def index

    @full_search = false
    backup_filter = Filter.new(:STATUS, :Claimed, :NOT)
    default_filter_1 = Filter.new(:STATUS, :Claimed)
    default_filter_2 = Filter.new(:CURRENT_REVIEWER, current_user.email)


    @@solr_connection ||= RSolr.connect url: Rails.application.config.solr[Rails.env]['url']

    @@solr_docs ||= []

    unless session[:review_dash_filters]
      # this is the first time this action is ran,
      # so assign default filters
      session[:review_dash_filters] = []
      # assign a session variable to track all the facets we filter on
      session[:review_dash_filters] << default_filter_1 << default_filter_2
    end

    @disable_search_form = true #stop ora search form appearing


    if params[:remove_filter]

      if params[:remove_filter][:predicate]
        params[:remove_filter][:predicate] = nil if params[:remove_filter][:predicate].empty?
      end

      session[:review_dash_filters].delete_if do |f|
        f.facet == params[:remove_filter][:facet].to_sym &&
          f.value.to_s == params[:remove_filter][:value].to_s &&
          f.predicate == params[:remove_filter][:predicate]
      end
    end


    if params[:apply_filter]
      session[:review_dash_filters].clear

      unless %w[All ALL all].include? params[:apply_filter].first
        params[:apply_filter].each do |h|
          session[:review_dash_filters] << Filter.new(h[:facet].to_sym,
                                                      h[:value].to_s,
                                                      h[:predicate])
        end
      end
    end


    # user is doing full-text search
    if params[:search]
      @full_search = true
      session[:review_dash_filters].clear
      query = params[:search].to_s.gsub(%r{\s}, '+')
      Solrium.attributes.each do |facet|
        session[:review_dash_filters] << Filter.new(facet, query)
      end

    end

    # user is claiming/unclaiming items
    if params[:claim]
      usr_name = (Rails.env.production? ? current_user.full_name : current_user.email)


      #get the solr doc we want to update
      response = @@solr_connection.get 'select',
        :params => {q: "id:#{params[:claim_id]}"}
      unless response["response"]["docs"].size == 1
        raise "Wrong number of documents to update!"
      end


      solr_doc = mark_doc_as_claimed(response["response"]["docs"].first, usr_name) if %w(on yes true).include? params[:claim]

      solr_doc = mark_doc_as_unclaimed(response["response"]["docs"].first) if %w(off no false).include? params[:claim]

      #update back to Solr
      if  update_solr_doc( solr_doc ) == 0 # success
        if %w(on yes true).include? params[:claim]
          flash[:notice] = "Item #{params[:claim_id]} has been successfully claimed by #{usr_name}!."
          get_solr_records( build_query([] << default_filter_1 << default_filter_2) )
        end
        if %w(off no false).include? params[:claim]
          flash[:notice] = "Item #{params[:claim_id]} has been successfully un-claimed by #{usr_name}!."
          get_solr_records( build_query([] << default_filter_1 << default_filter_2) )
        end
      else
        flash[:error] = "Item #{params[:claim_id]}- Claim state could not be changed due to Solr update error!"
      end
      return
    end

    full_query = params[:search] ?
      build_query(session[:review_dash_filters], " OR ")  :
      build_query(session[:review_dash_filters])

    get_solr_records(full_query)


  end


  private

  # Gets the solr query executed and sets two instance variables:
  # One for all found documents (@docs_list) and one for all
  # relevant facets (@facets)
  #
  # @param query [?] The Solr query string
  # @return N/A
  def get_solr_records(query)
    response = solr_search(query,  params[:page] ? params[:page].to_i : 1)
    @docs_found = response['response']['numFound']

    if @docs_found < 1
      #TODO: no Solr records, render error page
    else
      @facets = response['facet_counts']['facet_fields']
      @docs_list = response['response']['docs']
    end

  end


  # Executes the solr query
  # @return N/A
  def solr_search(query, page = 1)
    logger.info "Solr search query: #{query}"

    @@solr_connection.paginate page, 10, "select", params: {
      q: query,
      facet: true,
      'facet.field' => SolrFacets.values,
      'facet.limit' => 20,
      wt: "ruby"
    }

  end


  # Ensures the right solr metadata fields are created and populated
  # in order for the document to be claimed by the current user
  #
  # @param solr_doc [Hash] document metadata retrieved from Solr
  # @param user [String] The current user's full name or email
  # @return String the modified solr document
  def mark_doc_as_claimed(solr_doc, user)
    # make sure relevant fields are there
    solr_doc["MediatedSubmission_current_reviewer_id_ssim"] = [] unless solr_doc["MediatedSubmission_current_reviewer_id_ssim"]
    solr_doc["MediatedSubmission_status_ssim"] = [] unless solr_doc["MediatedSubmission_status_ssim"]
    solr_doc["MediatedSubmission_all_reviewer_ids_ssim"] = [] unless solr_doc["MediatedSubmission_all_reviewer_ids_ssim"]
    # now set the right values
    solr_doc["MediatedSubmission_all_reviewer_ids_ssim"].push user
    solr_doc["MediatedSubmission_current_reviewer_id_ssim"] = Array.new(1, user)
    solr_doc["MediatedSubmission_status_ssim"].push Sufia.config.claimed_status
    solr_doc
  end


  # Ensures the right solr metadata fields are created and populated
  # in order for the document to be claimed by the current user
  #
  # @param solr_doc [Hash] document metadata retrieved from Solr
  # @param user [String] The current user's full name or email
  # @return String the modified solr document
  def mark_doc_as_unclaimed(solr_doc)
    previous_reviewer = solr_doc["MediatedSubmission_all_reviewer_ids_ssim"][-2]
    previous_status = solr_doc["MediatedSubmission_status_ssim"][-2]
    solr_doc["MediatedSubmission_all_reviewer_ids_ssim"].push previous_reviewer
    solr_doc["MediatedSubmission_current_reviewer_id_ssim"] = Array.new(1, previous_reviewer)
    solr_doc["MediatedSubmission_status_ssim"].push previous_status
    solr_doc
  end


  # Updates the solr document. Update is a 2-stage process, add
  # + commit
  #
  # @param solr_doc [Hash] Solr document to be updated
  # @return Integer 0 if update was successful
  # @note Solr's #add and #commit methods will raise exceptions
  # on failure
  def update_solr_doc(solr_doc)
    res = @@solr_connection.add solr_doc
    res = @@solr_connection.commit
    res['responseHeader']['status']

  end

  def full_text_search( search_term )
    joined_results = []
    Solrium.each do |nice_name, solr_name|
      qs = "#{nice_name.to_s.downcase}=#{search_term}"
      rs = QueryStringSearch.new(@@solr_docs, qs).results
      joined_results.concat( rs ) if rs.size > 0
    end
    joined_results
  end


  # Builds a Solr query string from a list of Filter objects
  # Each filter is appended to the query string as a conjuncture (AND)
  # unless a different operator is passed as an argument
  #
  # @param filter_list [Array] the list of Filter objects
  # @param operator [String] the operator between clauses
  # @return [String] a Solr query string
  def build_query(filter_list, operator = " AND ")
    query = "*:*" # if no filters, get everything
    unless filter_list.empty?
      query.clear
      (0...filter_list.length).step(1).each do |index|
        filter = filter_list[index]
        filter_value = filter.value.to_s.gsub(%r{\s}, '+')
        query << "#{Solrium.lookup(filter.facet)}:#{filter_value}"
        if %w[NOT not Not].include? filter.predicate.to_s
          query = query.prepend('NOT ')
        end
        query << operator unless index == filter_list.length - 1
      end
    end
    query

  end



  def full_search_query(term)
    q_string = ""
    Solrium.values.each_with_index do |solr_field, i|
      q_string = q_string + "#{solr_field}:#{term}"
      q_string = q_string + " OR " unless i == Solrium.values.size - 1
    end
    q_string
  end




  def find_doc(doc_id)
    if @docs_list
      idx = docs_list.find_index {|doc| doc['id'] == doc_id}
      @docs_list[idx]
    end
  end

end

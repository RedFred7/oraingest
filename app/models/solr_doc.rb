class SolrDoc


  # any instance variables we want to expose to the world as-is, without
  # any manipulation, go here
  attr_accessor :id, :all_reviewers, :status, :current_reviewer, :title, :abstract, :creator, :type, :depositor, :date_published, :date_accepted

  attr_reader :model


  SOLR_CONNECTION ||= RSolr.connect url: Rails.application.config.solr[Rails.env]['url'] 


  # constructs a SolrItem based on a SolrResponse document.
  # Reads the properties defined in Solrium module and -for each- sets
  # instance variables and accessor methods
  #
  # @param solr_response_item [SolrResponse] the hash-like representation
  # of a Solr document
  def initialize(solr_response_item)
    Solrium.each do |nice_name, solr_name|
      self.instance_variable_set("@#{nice_name.to_s.downcase}", solr_response_item[solr_name])
    end
    # ensure all_reviewers is a valid_object
    self.all_reviewers = [] unless self.all_reviewers 
  end

  def to_hash
    hash = {}
    instance_variables.each do |var|
      var_name = var.to_s.delete("@")
      key = Solrium.lookup(var_name)
      hash[key] = (instance_variable_get(var) || Array.new)
    end
    hash
  end

  def allowed_transitions
    return [] if self.last_status.empty?
    Sufia.config.next_workflow_status[self.last_status]
  end

  def transition_allowed?(new_status)
    allowed_transitions.include?  new_status
  end

  def is_it_claimed?
    self.last_status == Sufia.config.claimed_status
  end

  # define explicit getters for instance variables we want to refine
  # before exposing to the outside
  def title
    return "" unless @title
    return @title if @title.is_a? String
    return @title.first if @title.is_a? Array
  end

  def abstract
    return "" unless @abstract
    return @abstract if @abstract.is_a? String
    return @abstract.first if @abstract.is_a? Array
  end

  def creator
    @creator ? @creator.join(',') : ""
  end

  def contributor
    @contributor ? @contributor.join(',') : ""
  end

  def last_status
    return "" unless @status
    @status.empty? ? "" : @status.last
  end

  def type
    @type ? @type.first : ""
  end

  def depositor
    @depositor ? @depositor.first : ""
  end

  def current_reviewer
    @current_reviewer ? @current_reviewer.first : ""
  end


  def date_published
    if @date_published && @date_published.is_a?(Array)
      @date_published.first
    elsif @date_published && @date_published.is_a?(String)
      @date_published
    else
      ""
    end
  end


  def date_accepted
    if @date_accepted && @date_accepted.is_a?(Array)
      @date_accepted.first
    elsif @date_accepted && @date_accepted.is_a?(String)
      @date_accepted
    else
      ""
    end
  end

  def subject
    @subject ? @subject : ""
  end

  def rt_tickets
    @rt_tickets || []
  end

  ############################
  ##
  # Solr data operations
  ##
  ###########################
  def save
    res = SOLR_CONNECTION.add self.to_hash
    res = SOLR_CONNECTION.commit if res['responseHeader']['status'] == 0
    res['responseHeader']['status'] == 0
  end

  def delete
    res = SOLR_CONNECTION.delete_by_id(self.id)
    res = SOLR_CONNECTION.commit if res['responseHeader']['status'] == 0
    res['responseHeader']['status'] == 0
  end  

  ############################
  ##
  # Class-wide operations
  ##
  ###########################
  def self.delete_all

    res = SOLR_CONNECTION.delete_by_query '*:*'
    res = SOLR_CONNECTION.commit if res['responseHeader']['status'] == 0
    res['responseHeader']['status'] == 0
  end

  def self.find_by_id(pid)
    response = SOLR_CONNECTION.get 'select', :params => {:q => "id:#{pid}"}
    if response['responseHeader']['status'] == 0
      if response['response']['numFound'] == 1
        SolrDoc.new( response['response']['docs'].first )
      else raise "More than 1 Solr doc found for pid '#{pid}'"
      end
    else
      raise "Solr error #{res['responseHeader']['status']} occured"\
        "while looking for pid '#{pid}'"
    end
  end


  def self.find_by_attrib(attrib_name, attrib_value, predicate=nil)
    found = []
    response = SOLR_CONNECTION.get 'select', :params => {:q => "#{predicate.to_s} #{Solrium.lookup(attrib_name)}:#{attrib_value}"}
    if response['responseHeader']['status'] == 0
      response['response']['docs'].each do |solr_hash|
        found << SolrDoc.new( solr_hash )
      end
    else
      raise "Solr error #{res['responseHeader']['status']} occured"\
        "while looking for status '#{status}'"
    end
    found
  end  

end

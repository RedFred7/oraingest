class SolrDoc


  # any instance variables we want to expose to the world as-is, without
  # any manipulation, go here
  attr_writer :current_reviewer, :title
  attr_accessor :id, :all_reviewers, :status


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
    @title ? @title.first : ""
  end

  def abstract
    @abstract ? @abstract.first : ""
  end

  def creator
    @creator ? @creator.join(',') : ""
  end

  def contributor
    @contributor ? @contributor.join(',') : ""
  end

  def last_status
    @status ? @status.last : ""
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
    @date_published ? @date_published.first : ""
  end

  def date_accepted
    @date_accepted ? @date_accepted.first : ""
  end

  def subject
    @subject ? @subject : ""
  end


end

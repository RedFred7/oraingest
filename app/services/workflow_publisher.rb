# ***********************************************************
# Modified By : Bhavana Ananda (Calvin Butcher)
# Date        : 23/03/2016

# Removed Databank
# Regeneration of DC
# ***********************************************************

# require 'ora/data_doi'
require 'active_support/core_ext/hash/indifferent_access'
require 'builder'
require 'nokogiri'
require 'popen4'

class WorkflowPublisher

  attr_accessor :parent_model

  def initialize(model)
    @parent_model = model
  end

  def perform_action(current_user)
    mint_and_check_doi
    send_email(current_user) if Rails.env.production?
    if parent_model.model_klass == 'Dataset'
      regenerate_DC(current_user)
    end
    publish_record(current_user)
  end

  private

  def target_workflow_id
    'MediatedSubmission'
  end

  def target_workflow
    @target_workflow ||= parent_model.workflows.select{|wf| wf.identifier.first == target_workflow_id}.first
  end

  def current_status
    target_workflow.current_status
  end

  # Mint a doi or check a DOI if doi_requested? and in review status
  def mint_and_check_doi
    return unless parent_model.instance_of? Dataset

    unless Sufia.config.user_edit_status.include?(current_status)
      if parent_model.doi_requested? && !parent_model.doi_registered?
        parent_model.set_dataset_doi
      end
      unless status
        @parent_model.workflowMetadata.update_status(Sufia.config.failure_status, msg)
      end
    end
  end

  def send_email(current_user)
    record_url = Rails.application.routes.url_helpers.url_for(
      controller: parent_model.model_klass.tableize,
      action: 'show',
      id: parent_model.id
    )
    data = {'record_id' => parent_model.id, 'record_url' => record_url, 'doi_requested'=>parent_model.doi_requested?}
    if parent_model.doi_requested? && !parent_model.doi_registered?
      data['doi'] = parent_model.doi(mint=false)
    end
    parent_model.datastreams['workflowMetadata'].send_email(target_workflow_id, data, current_user, parent_model.model_klass)
  end


  def regenerate_DC(current_user)
    # Errors for DC regerneration are logged to '[project-directory]/log/dc_regenerator.log'
    dc_regen_cmd = "ora_dcregenerator --pids " + @parent_model.id.to_s
    dc_regen_cmd = dc_regen_cmd + " --host localhost:8080 --user " + Rails.application.config.fedora[Rails.env]['user']
    dc_regen_cmd = dc_regen_cmd + " --pass  " + Rails.application.config.fedora[Rails.env]['password']
    dc_regen_cmd = dc_regen_cmd + "  >> log/dc_regenerator.log"

    # Popen - Runs the above at the shell and returns exit code and error for logging
    status =
    POpen4::popen4(dc_regen_cmd) do |stdout, stderr, stdin, pid|
      stdin.close
      puts "pid        : #{ pid }"
      puts "stdout     : #{ stdout.read.strip }"
      puts "stderr     : #{ stderr.read.strip }"
      stdout.gets
      stderr.gets
    end
    puts "status     : #{ status.inspect }"
    puts "exitstatus : #{ status.exitstatus }"
    # To Do [ 21/4/2016 ] - Show if any excetipns on the UI History with DCRegeneration status
  end


  def publish_record(current_user)
    # Send pid and list of open datastreams to queue
    # If datastreams are empty, that means record is all dark
    #1 Check if ready to publish
    return unless ready_to_publish?
    msg = []
    status = nil

    #2 check minimum metadata
    ans, msg2 = check_minimum_metadata
    msg.concat msg2
    status = Sufia.config.failure_status unless ans

    #3 Add record to publish workflow
    unless status == Sufia.config.failure_status
      ans, msg2 = add_to_queue
      msg.concat msg2
      status = Sufia.config.verified_status
    end
    parent_model.workflowMetadata.update_status(status, msg)
  end

  def ready_to_publish?
    return unless target_workflow

    queue_option = Sufia.config.publish_to_queue_options[parent_model.model_klass.downcase]
    return unless queue_option && queue_option.include?(current_status)

    occurences = target_workflow.all_statuses.select{|s| s == current_status}
    occurence = queue_option[current_status]['occurence']
    return (occurences.length == occurence) || occurence == 'all'
  end

  def check_minimum_metadata
    status = true
    msg = []
    # descMetadata has to exist
    unless parent_model.datastreams.keys().include? 'descMetadata'
      status = false
      msg << 'No descMetadata available.'
    end
    # All of the access rights should be in place
    unless parent_model.has_all_access_rights?
      status = false
      msg << 'Not all files or the catalogue record has embargo details'
    end

    # The metadata for registering DOI should exist
    if parent_model.model_klass == 'Dataset' && parent_model.doi_requested?
      unless parent_model.doi_registered?
        payload = parent_model.doi_data

        error = validate_required_fields(payload).blank?
        unless error.blank?
          status = false
          msg << error
        end
      end
    end

    return status, msg
  end

  required_attributes = ['identifier', 'creator', 'title', 'publisher', 'publicationYear' ].freeze
  def validate_required_fields(payload)
    errors, error_msg = [], ""
    required_attributes.each do |attr|
      errors << "#{attr}" if payload.with_indifferent_access[attr].try(:blank?)
    end

    if errors.any?
      error_msg = "The following attributes are missing: " + errors.join(", ")
      @parent_model.workflowMetadata.update_status(Sufia.config.failure_status, error_msg)
    end
    error_msg
  end

  def add_to_queue
    msg = []
    status = true
    open_access_content = @parent_model.list_open_access_content

    # 'DC' datastream also needs to be copied into ORA-PUBLIC after DC_regeneration creates more DC elements from descMetadata in ORA-DEPOSIT
    datastreams_to_be_copied = open_access_content + ['DC']

    open_access_content_filenames = @parent_model.list_open_access_content_filenames
    number_of_files = (
      open_access_content.select { |key| key.start_with?('content') }
    ).length.to_s
    msg << "Open access datastreams: %s."%open_access_content.join(', ')

    # Add to ora publish queue
    # Adding open access content filenames to be pulled into RSyncQ redis queue in ORA-PUBLIC
    # Adding open access content filenames to be pulled into RSyncQ redis queue in ORA-PUBLIC

    args = {
      'pid' => @parent_model.id.to_s,
      'datastreams' => datastreams_to_be_copied,
      'model' => @parent_model.model_klass,
      'numberOfFiles' => number_of_files,
      'open_access_content_filenames' => open_access_content_filenames,
      'rsync_yes_no' => parent_model.model_klass == 'Dataset'
    }
    Resque.redis.rpush(Sufia.config.ora_publish_queue_name, args.to_json)

    return status, msg
  end

end

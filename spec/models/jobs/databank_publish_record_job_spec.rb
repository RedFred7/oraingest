require 'rails_helper'

describe DatabankPublishRecordJob do
  
  let(:model) { Thesis.create }
  
  describe '.perform' do
  
    it 'should pass data to MigrateData and trigger migrate process' do
      pid = model.id
      datastreams = model.list_open_access_content
      model_class = model.model_klass
      number_of_files = 1
      expect_any_instance_of(Ora::MigrateData).to receive(:migrate)
      DatabankPublishRecordJob.perform(
        pid,
        datastreams,
        model_class,
        number_of_files
      )
    end
    
  end
  
end

require 'rails_helper'

describe 'MigrateData' do
  let(:model) { Thesis.create }
  let(:migrate_data) {
    Ora::MigrateData.new(
      model.id,
      model.list_open_access_content,
      model.class.to_s,
      '1'
    ) 
  }
  let(:id_for_url){ model.id.split(':').last }
  let(:stub_dataset_not_found) do
    stub_request(:get, "http://sandbox_user:sandbox@10.0.0.173/sandbox/datasets/#{id_for_url}").
         to_return(:status => 404)
  end
  let(:stub_dataset_found) do
    stub_request(:get, "http://sandbox_user:sandbox@10.0.0.173/sandbox/datasets/#{id_for_url}").
         to_return(:status => 200, body: {foo: 'bar'}.to_json)
  end
  let(:stub_create_new_dataset) do
    stub_request(:post, "http://sandbox_user:sandbox@10.0.0.173/sandbox/datasets").
         to_return(:status => 200)
  end
  let(:stub_push_data_to_dataset) do
    stub_request(:post, "http://sandbox_user:sandbox@10.0.0.173/sandbox/datasets/#{id_for_url}").
         to_return(:status => 200)
  end

  describe '#migrate' do
    
    context 'dataset already exists' do
      
      before do
        stub_dataset_found
      end
    
      it 'should upload file' do
        stub_push_data_to_dataset
        migrate_data.migrate
      end
    
    end
    
    context 'dataset does not exist' do
      
      before do
        stub_dataset_not_found
      end
    
      it 'should create dataset then upload data' do
        stub_create_new_dataset
        stub_push_data_to_dataset
        migrate_data.migrate
      end
    
    end
    
    context 'after data uploaded' do
      
      before do
        stub_dataset_found
        stub_push_data_to_dataset
      end
      
      it 'should save model' do
        expect_any_instance_of(Dataset).to receive(:save!)
        migrate_data.migrate
      end
      
      it 'should tidy up files' do
        expect_any_instance_of(Dataset).to receive(:delete_dir)
        migrate_data.migrate
      end
      
      it 'should add to next queue' do
        Resque.redis.flushdb
        migrate_data.migrate
        data = JSON.parse(Resque.redis.rpop(Sufia.config.ora_publish_queue_name))
        expect(data['pid']).to eq(model.id.to_s)
      end
      
    end
    
  end
  

end


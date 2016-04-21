#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'rake/testtask'
require 'coveralls/rake/task'
require 'rsolr'
require_relative 'test/lib/data_generator'
include DataGenerator


namespace :test do

	%w(features functional helpers performance unit).each do |name|
		Rake::TestTask.new(name) do |t|
		t.libs = %W(lib/#{ name } test test/#{ name })
		t.pattern = "test/#{ name }/**/*_test.rb"
		end
	end

	Rake::TestTask.new(all: [:spec, 'test:unit', 'test:functional', 'test:integration' ])


	desc 'Create test data'
	task :seed_solr => :environment do
		WebMock.allow_net_connect!
		
		(self.delete_solr_test_data and self.create_solr_test_data) ? 
		puts("Solr seeded succesfully!") : puts("*** Solr seeding failed! ***")
	end

	desc 'Remove test data'
	task :unseed_solr => :environment do
		WebMock.allow_net_connect!
		puts("#{delete_solr_test_data} items cleared!")
	end

end


task :fred do
	puts "... running fred task"
	WebMock.allow_net_connect!
	solr = RSolr.connect :url => "http://localhost:8181/solr"
	res = solr.get 'select', :params => {:q => '*:*'}
	puts res['responseHeader']['status']
end

Coveralls::RakeTask.new
task :test_with_coveralls => [:spec, 'test:unit', 'coveralls:push']


OraHydra::Application.load_tasks





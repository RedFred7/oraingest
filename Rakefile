#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'rake/testtask'
require 'coveralls/rake/task'

namespace :test do

	%w(features functional helpers performance unit).each do |name|
		Rake::TestTask.new(name) do |t|
		t.libs = %W(lib/#{ name } test test/#{ name })
		t.pattern = "test/#{ name }/**/*_test.rb"
		end
	end

	Rake::TestTask.new(all: [:spec, 'test:unit', 'test:functional', 'test:integration' ])


	desc 'Create solr test data'
	task :seed_solr, [:how_many_items] => :environment do |t, args|
		WebMock.allow_net_connect!
		require_relative 'test/lib/data_generator'
		include DataGenerator
		(self.delete_solr_test_data and self.create_solr_test_data(args.how_many_items.to_i)) ? 
		puts("Solr seeded succesfully!") : puts("*** Solr seeding failed! ***")
	end

	desc 'Remove solr test data'
	task :unseed_solr => :environment do
		WebMock.allow_net_connect!
		require_relative 'test/lib/data_generator'
		include DataGenerator
		self.delete_solr_test_data ? puts("Solr cleared succesfully!")
		: puts("*** Solr clearing failed! ***")
	end

end


Coveralls::RakeTask.new
task :test_with_coveralls => [:spec,  'coveralls:push']


OraHydra::Application.load_tasks





#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'rake/testtask'
require 'coveralls/rake/task'
require 'rsolr'

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


task :fred do
	puts "++++++++++running fred task"
	# puts `echo $(curl -s -o /dev/null -w "%{http_code}" "http://localhost:$JETTY_PORT/solr/")`
	solr = RSolr.connect :url => "http://localhost:#{ENV['JETTY_PORT']}/solr"
	puts  "http://localhost:#{ENV['JETTY_PORT']}/solr"
	res = solr.get 'select', :params => {:q => '*:*'}
	puts res['responseHeader']['status']
end

Coveralls::RakeTask.new
task :test_with_coveralls => [:spec, 'test:unit', 'coveralls:push']
task :test_all => ['test:unit', 'test:functional']


OraHydra::Application.load_tasks





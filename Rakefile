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

	Rake::TestTask.new(all: [:spec, 'test:unit'])
end


Coveralls::RakeTask.new
task :test_with_coveralls => [:spec, 'test:unit', 'coveralls:push']


OraHydra::Application.load_tasks





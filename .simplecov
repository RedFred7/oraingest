=begin
We use three different test suites in this project: RSpec, Minitest and Cucumber. To avoid having to set up all the config options 3 times, in rails_helper.rb, test_helper.rb and in env.rb, we use this file as a central, unified configuration for any and all suites.
=end


SimpleCov.formatter = SimpleCov::Formatter::HTMLFormatter

SimpleCov.start 'rails' do 
  add_filter '/spec/'
  add_filter '/test/'
  add_filter '/config/'
  add_filter '/lib/qa/'
  add_filter '/lib/tasks/'
  add_filter '/lib/vocabulary/'
  add_filter '/vendor/'

  add_filter do |source_file|
    source_file.lines.count < 5
  end  

end 
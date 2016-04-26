source 'https://rubygems.org'

#ruby=2.1.5

gem 'rails', '4.0.3'

gem 'mysql2'
gem 'sqlite3'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 4.0.0'

  # Use Uglifier as compressor for JavaScript assets
  gem 'uglifier', '>= 1.3.0'

  # Use CoffeeScript for .js.coffee assets and views
  gem 'coffee-rails', '~> 4.0.0'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer', :platforms => :ruby
end

# Use jquery as the JavaScript library
gem 'jquery-rails'
gem 'jquery-validation-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

gem 'sufia', "~> 3.7.2"
gem 'kaminari'
gem 'jettywrapper', "~> 1.5.0"

gem 'font-awesome-sass'


# Use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.1.2'

# Use unicorn as the app server
gem 'unicorn'

gem "bootstrap-sass"
gem "devise"
gem "devise-guests", "~> 0.3"
gem 'devise-remote-user'
gem "unicode", :platforms => [:mri_18, :mri_19]

gem 'qa'

gem 'paperclip', '>=3.1.0'

gem 'rt-client'

group :development, :test do
  gem "rspec-rails", '~>3.2.0'
  gem 'chronic'
  gem "factory_girl_rails", "~> 4.2.1"
  gem 'capybara', '~>2.4.0'
  gem 'timecop', '~> 0.7.3'
  gem 'pry' #a powerful shell alternative to IRB
  gem 'awesome_print' #stylish pretty print.
  gem 'hirb' #tabular collection output
  gem 'pry-rails' #pry in the Rails console
  gem 'pry-doc' #to browse Ruby source
  gem 'pry-byebug' #debugger
  gem 'pry-stack_explorer' #navigate the call stack and frames
end

group :development do
  gem 'meta_request' #needed for RailsPanel Chrome plugin
  gem 'better_errors' #better error pages for Rails
  gem 'binding_of_caller' #Retrieve the binding of a method's caller
  gem 'travis' #for Travis-CI cli integration
  gem 'htmlbeautifier' #allows beautifying ERB files
end

group :test do
  gem 'webmock'     # Used in tests so external file location does not need to be present
  gem 'mock_redis'  # Used so redis does not need to be present during tests
  gem 'simplecov', :require => false
  gem 'coveralls', :require => false
  gem 'minitest-rails-capybara'
  gem 'minitest-reporters'
end

gem 'god'
gem 'query_string_search'
gem 'datacite_mds'   # gem to interface with Datacite MDS
gem 'hashids'     # generates hash ids based on a number
gem 'figaro'
gem 'open4'
gem 'POpen4'


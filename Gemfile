source 'https://rubygems.org'

ruby '2.5.1' # For Heroku, see also file .ruby-version

gem 'rails', '~> 5.0.7'
gem 'pg', '~> 0.18'
gem 'puma', '~> 3.0'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.2'

gem 'pry-rails' # friendlier rails console

# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

gem 'jquery-rails'
gem 'jquery-ui-rails'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
##TODO: gem 'jbuilder', '~> 2.5'
gem 'json_builder' #TODO:Voiko käyttää jbuilder

#TODO: Migrate to Amazon official gem which now includes S3
gem "aws-s3", require: "aws/s3", github: 'pre/aws-s3'

gem 'rollbar'
gem 'sendgrid' # sendgrid specific methods are used by mailers

gem 'ranked-model'
gem 'cancancan'
gem 'devise'
gem 'draper', '3.0.0.pre1'

gem 'delayed_job'
gem 'delayed_job_active_record'
gem 'formtastic'

group :development, :test do
  gem 'byebug', platform: :mri # usage: write "debugger" somewhere in code
  gem 'dotenv-rails'
  gem 'foreman'
end

group :development do
  gem 'web-console' # Access console on exception pages or by using <%= console %>
  gem 'listen', '~> 3.0.5'

  # keep application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'spring-commands-rspec'

  gem 'rubocop', require: false
  gem 'rubocop-rspec', require: false
end

group :test do
  gem 'database_cleaner'
  gem 'rspec'
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'guard-rspec'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

source 'https://rubygems.org'

ruby '2.3.1' # For Heroku, see also file .ruby-version

gem 'rails', '~> 5.0.0', '>= 5.0.0.1'
gem 'pg', '~> 0.18'
gem 'puma', '~> 3.0'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.2'

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

# gems that were updated when project was updated to Rails 3.2
gem 'delayed_job'
gem 'delayed_job_active_record'
gem 'formtastic'

group :development, :test do
  gem 'byebug', platform: :mri # usage: write "debugger" somewhere in code
  gem 'database_cleaner'
  gem 'rspec'
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'guard-rspec'
  gem 'dotenv-rails'
  gem 'foreman'
end

group :development do
  gem 'web-console' # Access console on exception pages or by using <%= console %>
  gem 'listen', '~> 3.0.5'
  gem 'spring' # keep application running in the background. Read more: https://github.com/rails/spring
  gem 'spring-watcher-listen', '~> 2.0.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

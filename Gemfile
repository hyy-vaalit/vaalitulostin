source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

ruby '3.3.9' # For Heroku, see also file .ruby-version

gem 'rails', '~> 7.1.5.2'
gem 'pg'
gem 'puma'
gem 'sass-rails'
gem 'uglifier'

gem 'jquery-rails'
gem 'jquery-ui-rails'

gem 'json_builder' # NOTE: json_builder is no longer maintained, replace with jbuilder

gem 'aws-sdk-rails', '~> 5'
gem 'aws-actionmailer-ses', '~> 1'
gem 'aws-sdk-s3', '~> 1'

gem 'rollbar'

gem 'ranked-model'
gem 'cancancan'
gem 'devise'
gem 'draper'

gem 'delayed_job'
gem 'delayed_job_active_record'
gem 'formtastic'

gem 'csv'

group :development, :test do
  gem 'byebug', platform: :mri # usage: write "debugger" somewhere in code
  gem 'dotenv-rails'
  gem 'solargraph'

  gem 'database_cleaner'
  gem 'fuubar'
  gem 'rspec'
  gem 'rspec-rails'
  gem 'rspec-json_expectations'
  gem 'factory_bot_rails'
  gem 'timecop'
  gem 'guard-rspec'
end

group :development do
  gem 'foreman'

  gem 'rubocop', require: false
  gem 'rubocop-rspec', require: false
  gem 'guard-rubocop'
  gem 'terminal-notifier-guard', require: false
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

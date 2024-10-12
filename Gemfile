source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

ruby '3.3.5' # For Heroku, see also file .ruby-version

gem 'rails', '~> 6.1.7.8'
gem 'pg'
gem 'puma'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'

# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

gem 'jquery-rails'
gem 'jquery-ui-rails'

gem 'json_builder' # NOTE: json_builder is no longer maintained, replace with jbuilder

# Provides aws-sdk-ses and aws-sdk-s3
# Newer version >=3.x requires Rails >=5.2
gem "aws-sdk-rails", '~> 2.1.0'
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
gem 'logger'

group :development, :test do
  gem 'byebug', platform: :mri # usage: write "debugger" somewhere in code
  gem 'dotenv-rails'
  gem 'solargraph'
end

group :development do
  gem 'foreman'

  # keep application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'spring-commands-rspec'

  gem 'rubocop', require: false
  gem 'rubocop-rspec', require: false
  gem 'guard-rubocop'
  gem 'terminal-notifier-guard', require: false
end

group :test do
  gem 'database_cleaner'
  gem 'fuubar'
  gem 'rspec'
  gem 'rspec-rails'
  gem 'rspec-json_expectations'
  gem 'factory_bot_rails'
  gem 'timecop'
  gem 'guard-rspec'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

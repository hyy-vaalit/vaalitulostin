source 'https://rubygems.org'

ruby '2.5.1' # For Heroku, see also file .ruby-version

gem 'rails', '~> 5.0.7'
gem 'pg', '~> 0.18'
gem 'puma', '~> 3.0'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.2'

gem 'pry-rails' # friendlier rails console
gem 'pry-highlight'
gem 'pry-doc'
gem 'pry-rescue'
gem 'pry-stack_explorer'

# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

gem 'jquery-rails'
gem 'jquery-ui-rails'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder'
gem 'json_builder' # TODO: json_builder is no longer maintained, use jbuilder

# TODO: Migrate to Amazon official gem which now includes S3
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
  gem 'pry-byebug'
  gem 'dotenv-rails'
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
  gem 'factory_girl_rails'
  gem 'timecop'
  gem 'guard-rspec'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

source 'https://rubygems.org'

gem 'rails', '4.2.0'
gem 'slimmer', '7.0.0'
gem 'gds-api-adapters', '16.1.0'
gem 'exception_notification', '4.0.1'
gem 'aws-ses', require: 'aws/ses'
gem 'unicorn', '4.8.1'

gem 'logstasher', '0.4.8'

gem 'shared_mustache', '0.1.3'

gem 'airbrake', '4.0.0'

gem 'chronic', '0.10.2'

group :assets do
  if ENV['FRONTEND_TOOLKIT_DEV']
    gem 'govuk_frontend_toolkit', path: '../govuk_frontend_toolkit_gem'
  else
    gem 'govuk_frontend_toolkit', '3.1.0'
  end
  gem 'sass-rails', '~> 4.0.2'
  gem 'uglifier', '>= 1.3.0'
end

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

group :development do
  gem "better_errors"
  gem "binding_of_caller"
end

group :development, :test do
  gem 'awesome_print'
  gem 'byebug'
  gem 'jasmine-rails'
  gem 'pry'
end

group :test do
  gem 'cucumber-rails', require: false
  gem 'launchy'
  gem 'rspec-rails'
  gem 'simplecov'
  gem 'webmock'
end

source 'https://rubygems.org'

gem 'rails', '4.2.7.1'
gem 'slimmer', '9.0.1'
gem 'gds-api-adapters', '~> 29.3'
gem 'unicorn', '~> 4.8.1'

gem 'logstasher', '~> 0.4.8'

gem 'shared_mustache', '~> 0.1.3'

gem 'airbrake', '~> 4.0.0'

gem 'chronic', '~> 0.10.2'

group :assets do
  if ENV['FRONTEND_TOOLKIT_DEV']
    gem 'govuk_frontend_toolkit', path: '../govuk_frontend_toolkit_gem'
  else
    gem 'govuk_frontend_toolkit', '~> 3.1.0'
  end
  gem 'sass-rails', '~> 4.0.2'
  gem 'uglifier', '~> 2.7', '>= 2.7.2'
end

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

group :development do
  gem "better_errors"
  gem "binding_of_caller"
  gem "quiet_assets"
end

group :development, :test do
  gem 'jasmine-rails', '~> 0.6.0'
  gem 'awesome_print'
  gem 'byebug'
  gem 'pry'
end

group :test do
  gem 'cucumber-rails', '~> 1.4.0', require: false
  gem 'launchy', '~> 2.4.2'
  gem 'rspec-rails', '~> 2.14.1'
  gem 'simplecov', '~> 0.9.0'
  gem 'webmock', '~> 1.17.1'
  gem 'govuk-content-schema-test-helpers', '~> 1.0.1'
end

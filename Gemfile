source 'https://rubygems.org'

gem 'rails', '~> 5.0.1'
gem 'slimmer', '~> 11.0.0'
gem 'gds-api-adapters', '~> 48.0'
gem 'unicorn', '~> 4.8.1'
gem 'logstasher', '~> 0.4.8'
gem 'shared_mustache', '~> 0.1.3'
gem 'airbrake', github: 'alphagov/airbrake', branch: 'silence-dep-warnings-for-rails-5'
gem 'chronic', '~> 0.10.2'
gem 'govuk_navigation_helpers', '~> 2.0.0'

group :assets do
  if ENV['FRONTEND_TOOLKIT_DEV']
    gem 'govuk_frontend_toolkit', path: '../govuk_frontend_toolkit_gem'
  else
    gem 'govuk_frontend_toolkit', '~> 7.0'
  end
  gem 'sass-rails', '~> 5.0'
  gem 'uglifier', '~> 2.7', '>= 2.7.2'
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
  gem 'jasmine-rails'
  gem 'awesome_print'
  gem 'rspec-rails', '~> 3.5.0'
  gem 'byebug'
  gem 'pry'
  gem 'govuk-lint', "~> 2.1.0"
end

group :test do
  gem 'cucumber-rails', '~> 1.4.0', require: false
  gem 'launchy', '~> 2.4.2'
  gem 'simplecov', '~> 0.9.0'
  gem 'webmock', '~> 1.17.1'
  gem 'rails-controller-testing'
  gem 'govuk-content-schema-test-helpers', '~> 1.0.1'
end

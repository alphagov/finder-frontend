source 'https://rubygems.org'

ruby File.read(".ruby-version").strip

gem 'rails', '~> 5.0.1'
gem 'slimmer', '~> 11.1.0'
gem 'gds-api-adapters', '~> 50.0'
gem 'shared_mustache', '~> 1.0.1'
gem 'govuk_app_config', '~> 1.0.0'
gem 'chronic', '~> 0.10.2'
gem 'govuk_ab_testing', '~> 2.4.1'
gem 'govuk_navigation_helpers', '~> 2.0.0'
gem 'govuk_publishing_components', '~> 1.10.0', require: false

gem 'govuk_frontend_toolkit', '~> 7.2'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '~> 2.7', '>= 2.7.2'

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
  gem 'rspec-rails', '~> 3.7.2'
  gem 'pry-byebug'
  gem 'govuk-lint', '~> 3.4.0'
end

group :test do
  gem 'cucumber-rails', '~> 1.5.0', require: false
  gem 'launchy', '~> 2.4.2'
  gem 'simplecov', '~> 0.15.0'
  gem 'webmock', '~> 3.1.1'
  gem 'rails-controller-testing'
  gem 'govuk-content-schema-test-helpers', '~> 1.5'
end

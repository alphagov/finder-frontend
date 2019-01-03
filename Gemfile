source 'https://rubygems.org'

ruby File.read(".ruby-version").strip

gem 'chronic', '~> 0.10.2'
gem 'gds-api-adapters', '~> 55.0'
gem 'govuk_ab_testing', '~> 2.4.1'
gem 'govuk_app_config', '~> 1.10.0'
gem 'govuk_document_types', '~> 0.9.0'
gem 'govuk_publishing_components', '~> 13.5.2'
gem 'rails', '~> 5.2.2'
gem 'shared_mustache', '~> 1.0.1'
gem 'slimmer', '~> 13.0.0'

gem 'govuk_frontend_toolkit', '~> 8.1'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '~> 4.1'

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
  gem 'govuk-lint', '~> 3.10.0'
  gem 'govuk_schemas', '~> 3.2'
  gem 'jasmine-rails'
  gem 'pry-byebug'
  gem 'rspec-rails', '~> 3.8.1'
end

group :test do
  gem 'cucumber-rails', '~> 1.6.0', require: false
  gem 'dalli', '~> 2.7.9'
  gem 'govuk-content-schema-test-helpers', '~> 1.6'
  gem 'launchy', '~> 2.4.2'
  gem 'rails-controller-testing'
  gem 'simplecov', '~> 0.16.1'
  gem 'webmock', '~> 3.5.1'
end

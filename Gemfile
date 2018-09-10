source 'https://rubygems.org'

ruby File.read(".ruby-version").strip

gem 'chronic', '~> 0.10.2'
gem 'gds-api-adapters', '~> 53.0'
gem 'govuk_ab_testing', '~> 2.4.1'
gem 'govuk_app_config', '~> 1.8.0'
gem 'govuk_document_types', '~> 0.7.1'
gem 'govuk_publishing_components', '~> 9.19.0'
gem 'rails', '~> 5.2.1'
gem 'shared_mustache', '~> 1.0.1'
gem 'slimmer', '~> 13.0.0'

gem 'govuk_frontend_toolkit', '~> 7.6'
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
  gem 'govuk-lint', '~> 3.9.0'
  gem 'jasmine-rails'
  gem 'pry-byebug'
  gem 'rspec-rails', '~> 3.8.0'
end

group :test do
  gem 'cucumber-rails', '~> 1.6.0', require: false
  gem 'govuk-content-schema-test-helpers', '~> 1.6'
  gem 'launchy', '~> 2.4.2'
  gem 'rails-controller-testing'
  gem 'simplecov', '~> 0.16.1'
  gem 'webmock', '~> 3.4.2'
end

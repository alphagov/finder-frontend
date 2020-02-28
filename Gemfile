source "https://rubygems.org"

ruby File.read(".ruby-version").strip

gem "chronic", "~> 0.10.2"
gem "dalli"
gem "gds-api-adapters", "~> 63.4"
gem "google-api-client"
gem "govuk_ab_testing", "~> 2.4.1"
gem "govuk_app_config", "~> 2.0.3"
gem "govuk_document_types", "~> 0.9.2"
gem "govuk_publishing_components", "~> 21.26.1"
gem "rails", "~> 6.0.2"
gem "slimmer", "~> 13.2.0"

gem "sass-rails", "~> 5.1.0"
gem "uglifier", "~> 4.2"
gem "whenever", "~> 1.0.0"

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem "sdoc", require: false
end

group :development do
  gem "better_errors"
  gem "binding_of_caller"
end

group :development, :test do
  gem "awesome_print"
  gem "dotenv-rails"
  gem "govuk_schemas", "~> 4.0"
  gem "jasmine-rails"
  gem "listen"
  gem "pry-byebug"
  gem "rspec-rails", "~> 4.0.0.beta4"
  gem "rubocop-govuk"
  gem "scss_lint-govuk"
end

group :test do
  gem "cucumber-rails", "~> 2.0.0", require: false
  gem "factory_bot"
  gem "govuk-content-schema-test-helpers", "~> 1.6"
  gem "govuk_test"
  gem "launchy", "~> 2.5.0"
  gem "rails-controller-testing"
  gem "simplecov", "~> 0.18.5"
  gem "timecop"
  gem "webmock", "~> 3.8.2"
end

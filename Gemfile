source "https://rubygems.org"

gem "rails", "7.0.4"

gem "chronic"
gem "dalli"
gem "gds-api-adapters"
gem "google-apis-drive_v3"
gem "govuk_ab_testing"
gem "govuk_app_config", github: "alphagov/govuk_app_config", branch: "csp-modernisation"
gem "govuk_publishing_components"
gem "mail", "~> 2.7.1"  # TODO: remove once https://github.com/mikel/mail/issues/1489 is fixed.
gem "rest-client"
gem "sassc-rails"
gem "slimmer"
gem "sprockets-rails"
gem "uglifier"
gem "whenever"

group :development do
  gem "better_errors"
  gem "binding_of_caller"
end

group :development, :test do
  gem "awesome_print"
  gem "dotenv-rails"
  gem "govuk_schemas"
  gem "govuk_test"
  gem "listen"
  gem "pry-byebug"
  gem "rspec-rails"
  gem "rubocop-govuk"
end

group :test do
  gem "climate_control"
  gem "cucumber-rails", require: false
  gem "factory_bot"
  gem "launchy"
  gem "rails-controller-testing"
  gem "simplecov"
  gem "timecop"
  gem "webmock"
end

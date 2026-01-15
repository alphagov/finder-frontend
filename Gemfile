source "https://rubygems.org"

ruby "~> 3.4.0"

gem "rails", "8.1.2"

gem "bootsnap", require: false
gem "chronic"
gem "connection_pool", "< 3" # Do not bump via Dependabot - https://github.com/alphagov/finder-frontend/pull/3921
gem "dalli"
gem "dartsass-rails"
gem "gds-api-adapters"
gem "govuk_ab_testing"
gem "govuk_app_config", "9.23.0"
gem "govuk_publishing_components"
gem "govuk_web_banners"
gem "rack-cors"
gem "rest-client"
gem "sprockets-rails"
gem "terser"

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

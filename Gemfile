source 'https://rubygems.org'
source 'https://BnrJb6FZyzspBboNJzYZ@gem.fury.io/govuk/'

gem 'rails', '4.0.2'
gem 'slimmer'
gem 'gds-api-adapters', github: 'alphagov/gds-api-adapters', branch: 'add-finder-api-adapter'
gem 'exception_notification', '4.0.1'
gem 'aws-ses', require: 'aws/ses'
gem 'unicorn', '4.8.1'

group :assets do
  if ENV['FRONTEND_TOOLKIT_DEV']
    gem 'govuk_frontend_toolkit', path: '../govuk_frontend_toolkit_gem'
  else
    gem 'govuk_frontend_toolkit', '0.41.0'
  end
  gem 'sass-rails', '~> 4.0.0'
  gem 'uglifier', '>= 1.3.0'
end

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

group :development, :test do
  gem 'debugger'
end

group :test do
  gem 'cucumber-rails', require: false
  gem 'rspec-rails'
  gem 'webmock'
end

# This file is copied to spec/ when you run 'rails generate rspec:install'
require "simplecov"
SimpleCov.start

require "slimmer/test"

ENV["RAILS_ENV"] ||= "test"
ENV["GOVUK_WEBSITE_ROOT"] ||= "https://www.test.gov.uk"
require File.expand_path("../config/environment", __dir__)
require "rspec/rails"
require "webmock/rspec"

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].sort.each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.check_pending! if defined?(ActiveRecord::Migration)
Rails.application.load_tasks

GovukAbTesting.configure do |config|
  config.acceptance_test_framework = :active_support
end

FactoryBot.definition_file_paths = %w[./spec/factories]
FactoryBot.find_definitions

RSpec.configure do |config|
  config.raise_errors_for_deprecations!

  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  # config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  # config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"

  config.before { Rails.cache.clear }
end

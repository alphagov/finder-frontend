# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path("config/application", __dir__)

if Rails.env.development? && ENV["LIVE"]
  puts "Pointing application at live dependencies..."
  ENV["GOVUK_APP_DOMAIN"] = "www.gov.uk"
  ENV["GOVUK_WEBSITE_ROOT"] = "https://www.gov.uk"
  ENV["PLEK_SERVICE_SEARCH_URI"] = "https://www.gov.uk/api"
  ENV["PLEK_SERVICE_CONTENT_STORE_URI"] = "https://www.gov.uk/api"
  ENV["PLEK_SERVICE_STATIC_URI"] = "assets.publishing.service.gov.uk"
  ENV["PLEK_SERVICE_WHITEHALL_FRONTEND_URI"] = "https://www.gov.uk"
end

FinderFrontend::Application.load_tasks

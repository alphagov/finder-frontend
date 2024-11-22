# Be sure to restart your server when you modify this file.

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  # Allow the autocomplete API to be accessed from any GOV.UK domain, including non-production ones.
  # This lets us use the API in local development "live" stacks as well as the GOV.UK Publishing
  # Components guide.
  allow do
    origins GovukContentSecurityPolicy::GOVUK_DOMAINS

    resource "/api/autocomplete.json",
             headers: :any,
             methods: %i[get]
  end
end

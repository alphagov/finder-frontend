# Be sure to restart your server when you modify this file.

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  # Allow the autocomplete API to be accessed from any GOV.UK domain, including
  # non-production ones. This enables autocomplete on CSV preview GOV.UK pages,
  # which are hosted on assets.publishing.service.gov.uk.
  # This also allows for local development usage.
  allow do
    origins %r{(www|dev|publishing\.service)\.gov\.uk\z}

    resource "/api/search/autocomplete*",
             headers: :any,
             methods: %i[get]
  end
end

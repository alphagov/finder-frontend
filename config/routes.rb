Rails.application.routes.draw do
  mount GovukPublishingComponents::Engine, at: "/component-guide"

  get "/sign-in", to: proc { [200, {}, %w[OK]] }

  get "/healthcheck/live", to: proc { [200, {}, %w[OK]] }
  get "/healthcheck/ready", to: GovukHealthcheck.rack_response(
    Healthchecks::RegistriesCache,
  )

  root to: redirect("/development") unless Rails.env.test?
  get "/development" => "development#index"

  get "/search" => "search#index", as: :search
  get "/search/opensearch" => "search#opensearch"

  if ENV["GOVUK_WEBSITE_ROOT"] =~ /integration/ || ENV["GOVUK_WEBSITE_ROOT"] =~ /staging/
    get "/test-search/search" => "search#index"
    get "/test-search/search/opensearch" => "search#opensearch"
  end

  # Helper to generate email signup routes
  get "/email/subscriptions/new", to: proc { [200, {}, [""]] }, as: :email_alert_frontend_signup

  get "/*slug/email-signup" => "email_alert_subscriptions#new", as: :new_email_alert_subscriptions
  post "/*slug/email-signup" => "email_alert_subscriptions#create", as: :email_alert_subscriptions

  get "/search/advanced" => "redirection#advanced_search"

  get "/*slug" => "redirection#redirect_covid", constraints: lambda { |request|
    topical_events = request.params["topical_events"]

    request.format == :html &&
      topical_events &&
      topical_events.include?("coronavirus-covid-19-uk-government-response")
  }

  get "/*slug" => "redirection#redirect_brexit", constraints: lambda { |request|
    related_to_brexit = request.params["related_to_brexit"]

    related_to_brexit && related_to_brexit.include?(ContentItem::BREXIT_CONTENT_ID)
  }

  # Whatever else you do here... keep this at the bottom of the file
  get "/*slug" => "finders#show", as: :finder
end

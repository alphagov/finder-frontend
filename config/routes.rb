Rails.application.routes.draw do
  mount GovukPublishingComponents::Engine, at: "/component-guide"

  get "/healthcheck/live", to: proc { [200, {}, %w[OK]] }
  get "/healthcheck/ready", to: proc { [200, {}, [JSON.generate({ status: :ok })]] }

  namespace :api do
    get "/search/autocomplete" => "autocompletes#index"
  end

  root to: redirect("/development") unless Rails.env.test?
  get "/development" => "development#index"

  get "/search" => "search#index", as: :search
  get "/search/opensearch" => "search#opensearch"

  # Helper to generate email signup routes
  get "/email/subscriptions/new", to: proc { [200, {}, [""]] }, as: :email_alert_frontend_signup

  if Rails.application.config.maintenance_mode
    get "/*slug/email-signup" => "maintenance#show"
    post "/*slug/email-signup" => "maintenance#show"
  else
    get "/*slug/email-signup" => "email_alert_subscriptions#new", as: :new_email_alert_subscriptions
    post "/*slug/email-signup" => "email_alert_subscriptions#create", as: :email_alert_subscriptions
  end

  get "/search/advanced" => "redirection#advanced_search"
  get "/search/latest" => "redirection#redirect_latest"
  get "/search/consultations" => "redirection#redirect_consultations"
  get "/search/statistics-announcements" => "redirection#redirect_statistics_announcements"

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

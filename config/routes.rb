FinderFrontend::Application.routes.draw do
  mount GovukPublishingComponents::Engine, at: "/component-guide"

  get "/sign-in", to: proc { [200, {}, %w[OK]] }
  get "/sign-out", to: proc { [200, {}, %w[OK]] }

  get "/healthcheck.json",
      to: GovukHealthcheck.rack_response(
        Healthchecks::RegistriesCache,
      )
  get "/healthcheck", to: proc { [200, {}, %w[OK]] }

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

  scope "/transition-check" do
    get "/results" => "brexit_checker#results", as: :transition_checker_results
    get "/questions" => "brexit_checker#show", as: :transition_checker_questions
    get "/email-signup" => "brexit_checker#email_signup", as: :transition_checker_email_signup
    post "/email-signup" => "brexit_checker#confirm_email_signup", as: :transition_checker_confirm_email_signup
    get "/save-your-results" => "brexit_checker#save_results", as: :transition_checker_save_results
    post "/save-your-results/sign-up" => "brexit_checker#save_results_sign_up", as: :transition_checker_save_results_sign_up
    get "/save-your-results/confirm", to: "brexit_checker#save_results_confirm", as: :transition_checker_save_results_confirm
    get "/save-your-results/email-signup", to: "brexit_checker#save_results_email_signup", as: :transition_checker_save_results_email_signup
    post "/save-your-results/confirm", to: "brexit_checker#save_results_apply"
    get "/saved-results", to: "brexit_checker#saved_results", as: :transition_checker_saved_results
    get "/edit-saved-results", to: "brexit_checker#edit_saved_results", as: :transition_checker_edit_saved_results
  end

  # Transition/Brexit checker email signup routes
  get "/email/subscriptions/new", to: proc { [200, {}, [""]] }, as: :email_alert_frontend_signup

  get "/*slug/email-signup" => "email_alert_subscriptions#new", as: :new_email_alert_subscriptions
  post "/*slug/email-signup" => "email_alert_subscriptions#create", as: :email_alert_subscriptions

  # Q&A frontend for "UK Nationals in the EU" (www.gov.uk/uk-nationals-in-the-eu)
  get "/uk-nationals-living-eu" => "qa_to_content#show"

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

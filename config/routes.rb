FinderFrontend::Application.routes.draw do
  mount JasmineRails::Engine => '/specs' if defined?(JasmineRails)
  mount GovukPublishingComponents::Engine, at: "/component-guide"

  get '/healthcheck.json', to: GovukHealthcheck.rack_response(
    Healthchecks::RegistriesCache,
  )
  get '/healthcheck', to: proc { [200, {}, %w[OK]] }

  root to: redirect('/development') unless Rails.env.test?
  get '/development' => 'development#index'
  get '/development/checklists' => 'development#checklists'

  get "/search" => "search#index", as: :search
  get "/search/opensearch" => "search#opensearch"

  if ENV['GOVUK_WEBSITE_ROOT'] =~ /integration/ || ENV['GOVUK_WEBSITE_ROOT'] =~ /staging/
    get "/test-search/search" => "search#index"
    get "/test-search/search/opensearch" => "search#opensearch"
  end

  get '/*slug/email-signup' => 'email_alert_subscriptions#new', as: :new_email_alert_subscriptions
  post '/*slug/email-signup' => 'email_alert_subscriptions#create', as: :email_alert_subscriptions

  # Q&A frontend for "Find EU Exit guidance for your business" (www.gov.uk/find-eu-exit-guidance-business)
  get '/prepare-business-uk-leaving-eu' => 'qa#show'

  # Q&A checklist frontend for brexit guidance
  get '/find-brexit-guidance/results' => 'checklist#results'
  get '/find-brexit-guidance' => 'checklist#show'

  # Q&A frontend for "UK Nationals in the EU" (www.gov.uk/uk-nationals-in-the-eu)
  get '/uk-nationals-living-eu' => 'qa_to_content#show'

  get '/search/advanced' => 'redirection#advanced_search'

  get '/redirect/announcements' => 'redirection#announcements'

  get '/redirect/publications' => 'redirection#publications'

  get '/redirect/statistics' => 'redirection#published_statistics'

  get '/redirect/statistics/announcements' => 'redirection#upcoming_statistics'

  get '/*slug' => 'finders#show', as: :finder
end

FinderFrontend::Application.routes.draw do
  mount JasmineRails::Engine => '/specs' if defined?(JasmineRails)
  mount GovukPublishingComponents::Engine, at: "/component-guide"

  get '/healthcheck', to: proc { [200, {}, ['OK']] }

  get "/search" => "search#index", as: :search
  get "/search/opensearch" => "search#opensearch"

  if ENV['GOVUK_WEBSITE_ROOT'] =~ /integration/ || ENV['GOVUK_WEBSITE_ROOT'] =~ /staging/
    get "/test-search/search" => "search#index"
    get "/test-search/search/opensearch" => "search#opensearch"
  end

  get '/*slug/email-signup' => 'email_alert_subscriptions#new', as: :new_email_alert_subscriptions
  post '/*slug/email-signup' => 'email_alert_subscriptions#create', as: :email_alert_subscriptions

  get '/search/advanced' => 'advanced_search_finder#show'

  get '/*slug' => 'finders#show', as: :finder
end

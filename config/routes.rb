FinderFrontend::Application.routes.draw do
  mount JasmineRails::Engine => '/specs' if defined?(JasmineRails)

  get '/*slug/email-signup' => 'email_alert_subscriptions#new', as: :new_email_alert_subscriptions
  post '/*slug/email-signup' => 'email_alert_subscriptions#create', as: :email_alert_subscriptions

  get '/*slug' => 'finders#show', as: :finder
end

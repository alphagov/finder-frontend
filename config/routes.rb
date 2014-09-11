FinderFrontend::Application.routes.draw do
  mount JasmineRails::Engine => '/specs' if defined?(JasmineRails)

  get '/:slug' => 'finders#show', as: :finder
  get '/:slug/email-signup' => 'finders#email_signup', as: :email_signup
end

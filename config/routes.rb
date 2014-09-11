FinderFrontend::Application.routes.draw do
  mount JasmineRails::Engine => '/specs' if defined?(JasmineRails)

  get '/:slug' => 'finders#show', as: :finder
  get '/:slug/signup' => 'finders#signup', as: :signup
end

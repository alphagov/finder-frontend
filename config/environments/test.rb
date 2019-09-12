FinderFrontend::Application.configure do
  # We use the non-default in memory cache store for development purposes.
  # It assumes memcached is running on localhost on the default port.
  #
  # More details:
  # https://guides.rubyonrails.org/caching_with_rails.html#activesupport-cache-memcachestore
  config.cache_store = :dalli_store, nil, { namespace: :finder_frontend, compress: true }

  config.cache_classes = true
  config.eager_load = false
  config.public_file_server.headers = { "Cache-Control" => "public, max-age=3600" }
  config.consider_all_requests_local = true
  config.action_controller.perform_caching = false
  config.action_dispatch.show_exceptions = false
  config.action_controller.allow_forgery_protection = false
  config.active_support.deprecation = :stderr
end

FinderFrontend::Application.configure do
  # Set GOVUK_ASSET_ROOT for heroku - for review apps we have the hostname set
  # at the time of the app being built so can't be set up in the app.json
  if !ENV.include?("GOVUK_ASSET_ROOT") && ENV["HEROKU_APP_NAME"]
    ENV["GOVUK_ASSET_ROOT"] = "https://#{ENV['HEROKU_APP_NAME']}.herokuapp.com"
  end

  config.cache_classes = true
  config.cache_store = :dalli_store, nil, { namespace: :finder_frontend, compress: true } unless ENV["HEROKU_APP_NAME"]
  config.eager_load = true
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true
  config.assets.js_compressor = :uglifier
  config.assets.compile = false
  config.assets.digest = true
  config.assets.version = "1.0"
  config.action_controller.asset_host = ENV["GOVUK_ASSET_HOST"]
  config.slimmer.asset_host = Plek.current.find("static")
  config.log_level = :info
  config.i18n.fallbacks = true
  config.active_support.deprecation = :notify
  config.public_file_server.enabled = ENV["RAILS_SERVE_STATIC_FILES"].present?
end

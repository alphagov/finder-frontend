FinderFrontend::Application.configure do
  config.cache_classes = true
  config.eager_load = true
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true
  config.public_file_server.enabled = false
  config.assets.js_compressor = :uglifier
  config.assets.compile = false
  config.assets.digest = true
  config.assets.version = '1.0'
  config.action_controller.asset_host = ENV['GOVUK_ASSET_HOST']
  config.slimmer.asset_host = Plek.current.find('static')
  config.log_level = :info
  config.i18n.fallbacks = true
  config.active_support.deprecation = :notify
  config.log_formatter = ::Logger::Formatter.new
  config.logstasher.enabled = true
  config.logstasher.logger = Logger.new("#{Rails.root}/log/#{Rails.env}.json.log")
  config.logstasher.suppress_app_log = true
  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?
end

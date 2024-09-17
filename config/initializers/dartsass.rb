APP_STYLESHEETS = {
  "application.scss" => "application.css",
  "components/_expander.scss" => "components/_expander.css",
  "components/_filter-panel.scss" => "components/_filter-panel.css",
  "components/_filter-section.scss" => "components/_filter-section.css",
  "components/_mobile-filters.scss" => "components/_mobile-filters.css",
  "views/_search.scss" => "views/_search.css",
}.freeze

all_stylesheets = APP_STYLESHEETS.merge(GovukPublishingComponents::Config.all_stylesheets)
Rails.application.config.dartsass.builds = all_stylesheets

Rails.application.config.dartsass.build_options << " --quiet-deps"

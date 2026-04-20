if ENV["GOVUK_RAILS_JSON_LOGGING"].present?
  GovukJsonLogging.configure do
    add_custom_fields do |fields|
      fields[:cache_max_age] = response.cache_control["max-age"]
      fields[:cache_public] = response.cache_control["public"]
    end
  end
end

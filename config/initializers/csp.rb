GovukContentSecurityPolicy.configure

Rails.application.config.content_security_policy do |p|
  p.connect_src(*Rails.application.config.content_security_policy.connect_src, "https://search-autocomplete-api.staging.publishing.service.gov.uk")
end

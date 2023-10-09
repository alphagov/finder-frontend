GOVUK_DOMAINS = [
    "*.publishing.service.gov.uk",
    "*.#{ENV['GOVUK_APP_DOMAIN_EXTERNAL'] || ENV['GOVUK_APP_DOMAIN'] || 'dev.gov.uk'}",
    "www.gov.uk",
    "*.dev.gov.uk",
  ].uniq.freeze

GovukContentSecurityPolicy.configure do |policy|
    policy.frame_ancestors :self, *GOVUK_DOMAINS
end
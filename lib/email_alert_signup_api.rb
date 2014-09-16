require 'gds_api/gov_uk_delivery'

class EmailAlertSignupAPI

  def initialize(dependencies = {})
    @delivery_api = dependencies.fetch(:delivery_api)
    @alert_identifier = dependencies.fetch(:alert_identifier)
    @alert_name = dependencies.fetch(:alert_name)
  end

  def signup_url
    ensure_topic_exists
    fetch_signup_url
  end

private
  attr_reader(
    :delivery_api,
    :alert_identifier,
    :alert_name,
  )

  def ensure_topic_exists
    delivery_api.topic(
      alert_identifier,
      alert_name,
    )
  end

  def fetch_signup_url
    delivery_api.signup_url(
      alert_identifier,
    )
  end
end

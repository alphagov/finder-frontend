require 'gds_api/gov_uk_delivery'

class EmailAlertSignupAPI

  def initialize(dependencies = {})
    @email_alert_api = dependencies.fetch(:email_alert_api)
    @attributes = dependencies.fetch(:attributes)
  end

  def signup_url
    subscriber_list.subscription_url
  end

private
  attr_reader :email_alert_api, :attributes

  def subscriber_list
    response = email_alert_api.find_or_create_subscriber_list("tags" => attributes)
    response.subscriber_list
  end
end

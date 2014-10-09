require 'gds_api/gov_uk_delivery'

class EmailAlertSignupAPI

  def initialize(dependencies = {})
    @email_alert_api = dependencies.fetch(:email_alert_api)
    @title = dependencies.fetch(:title)
    @tags = dependencies.fetch(:tags)
  end

  def signup_url
    subscriber_list.subscription_url
  end

private
  attr_reader(
    :email_alert_api,
    :title,
    :tags,
  )

  def alert_params
    {
      "title" => title,
      "tags" => tags,
    }
  end

  def subscriber_list
    @signup_url ||= email_alert_api.find_or_create_subscriber_list(alert_params)
  end
end

require 'email_alert_title_builder'

class EmailAlertSignupAPI
  def initialize(dependencies = {})
    @email_alert_api = dependencies.fetch(:email_alert_api)
    @attributes = dependencies.fetch(:attributes)
    @subscription_list_title_prefix = dependencies.fetch(:subscription_list_title_prefix)
    @available_choices = dependencies.fetch(:available_choices)
  end

  def signup_url
    subscriber_list['subscription_url']
  end

private

  attr_reader :email_alert_api, :attributes, :subscription_list_title_prefix, :available_choices

  def subscriber_list
    response = email_alert_api.find_or_create_subscriber_list("tags" => massaged_attributes, "title" => title)
    response['subscriber_list']
  end

  def title
    ::EmailAlertTitleBuilder.call(
      filter: attributes['filter'] || {},
      subscription_list_title_prefix: subscription_list_title_prefix,
      facets: available_choices
    )
  end

  def massaged_attributes
    attributes.dup.tap do |massaged_attributes|
      available_choices.each do |choice|
        facet_id = choice["facet_id"]
        value = (massaged_attributes['filter'] || {})[facet_id]
        next unless value
        massaged_attributes[facet_id] = value
      end
      massaged_attributes.delete("filter")
    end
  end
end

require 'email_alert_title_builder'
require 'validate_query'

class EmailAlertSignupAPI
  def initialize(dependencies = {})
    @email_alert_api = dependencies.fetch(:email_alert_api)
    @attributes = dependencies.fetch(:attributes)
    @subscription_list_title_prefix = dependencies.fetch(:subscription_list_title_prefix)
    @available_choices = dependencies.fetch(:available_choices)
    @default_attributes = dependencies.fetch(:default_attributes, {})
  end

  def signup_url
    subscriber_list['subscription_url']
  end

  def validate!
    validater.validate
  end

private

  attr_reader :email_alert_api, :attributes, :subscription_list_title_prefix, :available_choices, :default_attributes

  def subscriber_list
    response = email_alert_api.find_or_create_subscriber_list(
      "tags" => massaged_attributes,
      "title" => title,
      "content_purpose_supergroup" => content_purpose_supergroup,
    )
    response['subscriber_list']
  end

  def title
    ::EmailAlertTitleBuilder.call(
      filter: attributes['filter'] || {},
      subscription_list_title_prefix: subscription_list_title_prefix,
      facets: available_choices
    )
  end

  def content_purpose_supergroup
    massaged_attributes['content_purpose_supergroup'] || default_attributes['content_purpose_supergroup']
  end

  def massaged_attributes
    @massaged_attributes ||= attributes.dup.tap do |massaged_attributes|
      available_choices.each do |choice|
        key = choice["filter_key"] || choice["facet_id"]
        value = (massaged_attributes['filter'] || {})[key]
        next unless value

        massaged_attributes[key] = value
      end
      massaged_attributes.delete("filter")
    end
  end

  def validater
    @validater ||= ::ValidateQuery.new(
      massaged_attributes.merge(
        'content_purpose_supergroup' => content_purpose_supergroup
      )
    )
  end
end

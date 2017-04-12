require 'gds_api/gov_uk_delivery'
require 'digest/md5'

class EmailAlertSignupAPI
  def initialize(dependencies = {})
    @email_alert_api = dependencies.fetch(:email_alert_api)
    @attributes = dependencies.fetch(:attributes)
    @subscription_list_title_prefix = dependencies.fetch(:subscription_list_title_prefix)
    @email_filter_name = dependencies.fetch(:email_filter_name)
    @available_choices = dependencies.fetch(:available_choices)
    @filter_key = dependencies.fetch(:filter_key)
    if attributes['filter'].blank? && !available_choices.blank?
      raise ArgumentError, "User must choose at least one of the available options"
    end
  end

  def signup_url
    subscriber_list.subscription_url
  end

private

  attr_reader :email_alert_api, :attributes, :subscription_list_title_prefix, :email_filter_name, :available_choices, :filter_key

  def subscriber_list
    response = email_alert_api.find_or_create_subscriber_list(
      "tags" => massaged_attributes,
      "title" => title,
      "short_name" => short_name,
      "description" => description
    )
    response.subscriber_list
  end

  def title
    if available_choices.empty?
      title = subscription_list_title_prefix.to_s
    else
      number_of_filters_chosen = attributes.fetch("filter").length
      md5_hash_of_topics = Digest::MD5.hexdigest(topic_names.to_sentence)

      if number_of_filters_chosen == 1
        plural_or_single = "singular"
      else
        plural_or_single = "plural"
      end
      title = (
        subscription_list_title_prefix["many"].to_s +
        number_of_filters_chosen.to_s + " " +
        email_filter_name[plural_or_single] + " - " +
        md5_hash_of_topics
      )
    end

    title
  end

  def short_name
    # Limit short name to 255 characters due to a GovDelivery limit
    # We don't specifically check if the prefix alone is longer than 255
    # characters since a unit test in specialist-publisher verifies this
    if available_choices.empty?
      short_name = subscription_list_title_prefix.to_s
    else
      number_of_filters_chosen = attributes.fetch("filter").length

      if number_of_filters_chosen == 1
        plural_or_single = "singular"
      else
        plural_or_single = "plural"
      end
      short_name = (
        subscription_list_title_prefix["many"].to_s +
        number_of_filters_chosen.to_s + " " +
        email_filter_name[plural_or_single]
      )
    end

    short_name
  end

  def description
    if available_choices.empty?
      description = subscription_list_title_prefix.to_s
    else
      if attributes.fetch("filter").length == 1
        plural_or_single = "singular"
      else
        plural_or_single = "plural"
      end
      description = (
        subscription_list_title_prefix[plural_or_single].to_s +
        topic_names.to_sentence
      )
    end

    description
  end

  def topic_names
    attributes.fetch("filter").collect { |x| choice_hash_by_key(x).topic_name }
  end

  def choice_hash_by_key(key)
    available_choices.select { |x| x.key == key }[0]
  end

  def massaged_attributes
    massaged_attributes = attributes.dup
    if available_choices.empty?
      massaged_attributes.delete("filter")
    else
      massaged_attributes[@filter_key] = massaged_attributes.delete("filter")
    end
    massaged_attributes
  end
end

class BrexitChecker::AccountJwt
  def initialize(criteria_keys:, subscriber_list_slug:)
    @criteria_keys = criteria_keys
    @subscriber_list_slug = subscriber_list_slug
  end

  def encode
    JWT.encode payload, nil, "none"
  end

private

  attr_reader :criteria_keys, :subscriber_list_slug

  def payload
    {
      attributes: attributes,
    }
  end

  def attributes
    {
      transition_checker_state: {
        criteria_keys: criteria_keys,
        timestamp: Time.zone.now.to_i,
        email_topic_slug: subscriber_list_slug,
      },
    }
  end
end

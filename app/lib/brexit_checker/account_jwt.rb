class BrexitChecker::AccountJwt
  def initialize(criteria_keys:, subscriber_list_slug:, post_register_uri:, post_login_uri:)
    @criteria_keys = criteria_keys
    @subscriber_list_slug = subscriber_list_slug
    @post_register_uri = post_register_uri
    @post_login_uri = post_login_uri
  end

  def encode
    JWT.encode payload, nil, "none"
  end

private

  attr_reader :criteria_keys, :subscriber_list_slug, :post_register_uri, :post_login_uri

  def payload
    {
      attributes: attributes,
      post_register_oauth: post_register_uri,
      post_login_oauth: post_login_uri,
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

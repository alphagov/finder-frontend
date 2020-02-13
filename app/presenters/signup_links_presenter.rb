class SignupLinksPresenter
  def initialize(content_item, facets, keywords)
    @content_item = content_item
    @facets = facets
    @keywords = keywords
  end

  def signup_links
    {
      feed_link: feed_link,
      hide_heading: true,
      small_form: true,
      email_signup_link: email_signup_link.presence,
    }.compact
  end

private

  attr_reader :content_item, :facets, :keywords

  def email_signup_link
    signup_link = content_item.signup_link
    return signup_link if signup_link.present?

    "#{content_item.email_alert_signup['base_path']}#{query_string(alert_query_params)}" if content_item.email_alert_signup
  end

  def feed_link
    "#{content_item.base_path}.atom#{query_string(alert_query_params.merge(keywords: keywords))}"
  end

  def alert_query_params
    facets_with_filters = facets.select(&:has_filters?)
    query_params_array = facets_with_filters.map(&:query_params)
    query_params_array.inject({}, :merge)
  end

  def query_string(params)
    query_string = params.compact.to_query
    query_string.blank? ? query_string : "?#{query_string}"
  end
end

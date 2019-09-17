class SignupLinksPresenter
  def initialize(content_item, facets)
    @content_item = content_item
    @facets = facets
  end

  def signup_links
    {
      feed_link: feed_link,
      hide_heading: true,
      small_form: true,
      email_signup_link: (email_signup_link if email_signup_link.present?)
    }.compact
  end

private

  attr_reader :content_item, :facets

  def email_signup_link
    signup_link = content_item.signup_link
    return signup_link if signup_link.present?

    "#{content_item.email_alert_signup['web_url']}#{alert_query_string}" if content_item.email_alert_signup
  end

  def feed_link
    "#{content_item.base_path}.atom#{alert_query_string}"
  end

  def alert_query_string
    facets_with_filters = facets.select(&:has_filters?)
    query_params_array = facets_with_filters.map(&:query_params)
    query_string = query_params_array.inject({}, :merge).to_query
    query_string.blank? ? query_string : "?#{query_string}"
  end
end

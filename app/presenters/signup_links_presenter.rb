class SignupLinksPresenter
  def initialize(content_item, facets, keywords)
    @content_item = content_item
    @facets = facets
    @keywords = keywords
  end

  def signup_links
    # if there are 4 links, we start from 2
    # if there are 2 links, we start from 1
    [
      get_signup_link(0),
      get_signup_link(count_signup_links / 2),
    ]
  end

private

  attr_reader :content_item, :facets, :keywords

  def get_signup_link(pos)
    total_links = count_signup_links

    data_attributes = {
      hide_heading: true,
      small_form: true,
      feed_link:,
      email_signup_link: email_signup_link.presence,
    }.compact

    if email_signup_link && feed_link
      email_index_link = pos + 1
      feed_index_link = pos + 2
    elsif email_signup_link
      email_index_link = pos + 1
    elsif feed_link
      feed_index_link = pos + 1
    end

    if email_signup_link
      data_attributes[:email_signup_link_data_attributes] = {}
      data_attributes[:email_signup_link_data_attributes][:ga4_index] = {
        index_link: email_index_link,
        index_total: total_links,
      }
    end

    if feed_link
      data_attributes[:feed_link_data_attributes] = {}
      data_attributes[:feed_link_data_attributes][:ga4_index] = {
        index_link: feed_index_link,
        index_total: total_links,
      }
    end

    data_attributes
  end

  def count_signup_links
    total = 0
    total += 1 if feed_link
    total += 1 if email_signup_link
    total * 2
  end

  def email_signup_link
    signup_link = content_item.signup_link
    return signup_link if signup_link.present?

    if content_item.email_alert_signup
      "#{content_item.email_alert_signup['base_path']}#{query_string(alert_query_params)}"
    end
  end

  def feed_link
    unless content_item.is_licence_transaction?
      "#{content_item.base_path}.atom#{query_string(alert_query_params.merge(keywords:))}"
    end
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

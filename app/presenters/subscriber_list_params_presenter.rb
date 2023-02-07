class SubscriberListParamsPresenter
  def initialize(content_item, params)
    @content_item = content_item
    @params = params
  end

  def subscriber_list_params
    @subscriber_list_params ||= filtered_params
  end

private

  attr_reader :content_item, :params

  def filtered_params
    used_facets.each_with_object(hash_with_default_as_array) do |facet, hash|
      key = facet_filter_key(facet)
      value = facet_filter_value(facet)

      hash[key].concat Array(value)
    end
  end

  def used_facets
    facets.select do |facet|
      params[facet["facet_id"]].present?
    end
  end

  def facets
    return allowed_facets if can_modify_choices?

    email_filter_facets
  end

  def can_modify_choices?
    !content_item["details"]["email_filter_by"] == "all_selected_facets"
  end

  def email_filter_facets
    content_item["details"].fetch("email_filter_facets", [])
  end

  def allowed_facets
    email_filter_facets.reject { |facet| facet.key?("facet_choices") }
  end

  def hash_with_default_as_array
    Hash.new { |hash, key| hash[key] = [] }
  end

  def facet_filter_key(facet)
    facet["filter_key"] || facet["facet_id"]
  end

  def facet_filter_value(facet)
    return facet["filter_value"] if facet["filter_value"].present?

    values = Array(params[facet["facet_id"]])

    return facet_option_lookup_values(values, facet) if facet["option_lookup"].present?

    values
  end

  def facet_option_lookup_values(values, facet)
    facet["option_lookup"].select { |key, _| values.include? key }.values.flatten
  end
end

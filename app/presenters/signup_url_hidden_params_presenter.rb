class SignupUrlHiddenParamsPresenter
  def initialize(content_item, params)
    @content_item = content_item
    @params = params
  end

  def hidden_params
    @hidden_params ||= filtered_params
  end

private

  attr_reader :content_item, :params

  def filtered_params
    facets.each_with_object(hash_with_default_as_array) { |facet, hash|
      next unless params[facet['facet_id']].present?

      key = facet_filter_key(facet)
      value = facet_filter_value(facet)

      hash[key].concat Array(value)
    }
  end

  def facets
    allowed_facets.reject { |facet| facet.key?('facet_choices') }
  end

  def allowed_facets
    content_item['details'].fetch('email_filter_facets', [])
  end

  def hash_with_default_as_array
    Hash.new { |hash, key| hash[key] = []; }
  end

  def facet_filter_key(facet)
    facet['filter_key'] || facet['facet_id']
  end

  def facet_filter_value(facet)
    facet['filter_value'] || params[facet['facet_id']]
  end
end

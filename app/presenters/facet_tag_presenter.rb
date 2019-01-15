class FacetTagPresenter
  include ERB::Util

  def initialize(sentence_fragment, filter_params, base_url)
    @fragment = sentence_fragment
    @filter_params = filter_params
    @base_url = base_url
  end

  def present
    if fragment.nil? || fragment['values'].nil?
      {}
    end

    fragment['values'].map.with_index do |value, i|
      {
        preposition: i.zero? ? fragment['preposition'].titlecase : fragment['word_connectors'][:words_connector],
        text: html_escape(value['label']),
        link: remove_filter_link(value)
      }
    end
  end

private

  attr_reader :fragment, :filter_params, :base_url

  def remove_filter_link(value)
    filtered_params = filter_parameters(value)

    {
      href: "#{base_url}?#{Rack::Utils.build_nested_query(filtered_params)}",
      data: {
        facet: value['parameter_key'],
        name: value['name'],
        value: value['value']
      }
    }
  end

  def filter_parameters(fragment_value)
    values = filter_params.blank? ? [] : Array(filter_params.deep_dup)

    if values.is_a?(Hash)
      values.delete_if { |_key, val| val == fragment_value['value'] }
    else
      values.delete_if { |val| val == fragment_value['value'] }
    end
  end
end

class FacetFilterPresenter
  include ERB::Util

  def initialize(sentence_fragment, all_filter_params, base_url)
    @fragment = sentence_fragment
    @all_filter_params = all_filter_params
    @base_url = base_url
  end

  def present
    unless fragment.nil? || fragment['values'].nil?
      fragment['values'].each_with_index.map do |value, i|
        {
          preposition: i.zero? ? fragment['preposition'].titlecase : fragment['word_connectors'][:words_connector],
          text: html_escape(value['label']),
          link: create_remove_filter_link(value)
        }
      end
    else
      {}
    end
  end

private

  attr_reader :fragment, :all_filter_params, :base_url

  def create_remove_filter_link(value)
    filtered_params = all_filter_params.deep_dup
    values = filtered_params[fragment['key']] || []
    filtered_params[fragment['key']] = filter_parameters(values, value)

    {
      href: "#{base_url}?#{Rack::Utils.build_nested_query(filtered_params)}",
      data: {
        facet: value['parameter_key'],
        name: value['name'],
        value: value['value']
      }
    }
  end

  def filter_parameters(values, fragment_value)
    if values.is_a?(Hash)
      values.delete_if { |_key, val| val == fragment_value['value'] }
    else
      values.delete_if { |val| val == fragment_value['value'] }
    end
  end
end

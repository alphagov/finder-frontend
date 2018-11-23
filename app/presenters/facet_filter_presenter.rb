# class FacetFilterPresenter
#   include ERB::Util
#
#   def initialize(facet, all_filter_params, base_url)
#     @facet = facet
#     @all_filter_params = all_filter_params
#     @base_url = base_url
#   end
#
#   def present
#     fragment = facet.sentence_fragment
#     [
#     "<p class='filtered-results__preposition'>#{html_escape(fragment['preposition']).titlecase}</p>",
#         fragment_sentence(fragment)
#     ]
#   end
#
# private
#   attr_reader :facet, :all_filter_params, :base_url
#
#   def fragment_sentence(fragment)
#     values = fragment['values'].map { |value|
#       "<span>#{html_escape(value['label'])} #{create_remove_filter_link(fragment, value)}</span>"
#     }
#     "<p>#{values.to_sentence(fragment['word_connectors'])}</p>"
#   end
#
#   def create_remove_filter_link(fragment, value)
#     filtered_params = all_filter_params.deep_dup
#     values = filtered_params[fragment['key']] || []
#     filtered_params[fragment['key']] = filter_parameters(values, value)
#     href = "#{base_url}?#{Rack::Utils.build_nested_query(filtered_params)}"
#     "<a href='#{href}' class='remove-filter' data-facet='#{fragment['key']}' data-value='#{value['value']}' data-name='#{value['name']}'>x</a>"
#   end
#
#   def filter_parameters(values, fragment_value
#     if values.is_a?(Hash)
#       values.delete_if { |key, val| val == fragment_value['value'] }
#     else
#       values.delete_if { |val| val == fragment_value['value'] }
#     end
#   end
#
# end


class FacetFilterPresenter
  include ERB::Util

  def initialize(sentence_fragment, all_filter_params, base_url)
    @fragment = sentence_fragment
    @all_filter_params = all_filter_params
    @base_url = base_url
  end

  def present
    # binding.pry
    fragment['values'].each_with_index.map do |value, i|
      {
        preposition: i == 0 ? fragment['preposition'].titlecase : fragment['word_connectors'][:words_connector],
        text: html_escape(value['label']),
        link: create_remove_filter_link(value)
      }
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
      values.delete_if { |key, val| val == fragment_value['value'] }
    else
      values.delete_if { |val| val == fragment_value['value'] }
    end
  end

end

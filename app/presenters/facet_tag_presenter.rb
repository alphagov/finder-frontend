class FacetTagPresenter
  include ERB::Util

  def initialize(sentence_fragment, hide_facet_tag)
    @fragment = sentence_fragment
    @hide_facet_tag = hide_facet_tag
  end

  def present
    return {} if @fragment.nil? || @fragment['values'].nil? || @hide_facet_tag

    @fragment['values'].map.with_index do |value, i|
      {
        preposition: i.zero? ? @fragment['preposition'].titlecase : @fragment['word_connectors'][:words_connector],
        text: html_escape(value['label']),
        data_facet: value['parameter_key'],
        data_name: value['name'],
        data_value: value['value']
      }
    end
  end
end

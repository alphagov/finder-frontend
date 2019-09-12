class FacetTagPresenter
  include ERB::Util

  def initialize(sentence_fragment, hide_facet_tag, i_am_a_topic_page_finder: false)
    @hide_facet_tag = hide_facet_tag
    @i_am_a_topic_page_finder = i_am_a_topic_page_finder
    @fragment = remove_taxonomy_facets(sentence_fragment)
  end

  def present
    return {} if @fragment.nil? || @hide_facet_tag

    @fragment["values"].map.with_index do |value, i|
      {
        preposition: i.zero? ? @fragment["preposition"].titlecase : @fragment["word_connectors"][:words_connector],
        text: html_escape(value["label"]),
        data_facet: value["parameter_key"],
        data_name: value["name"],
        data_value: value["value"],
        data_track_label: value["label"],
      }
    end
  end

private

  def remove_taxonomy_facets(fragment)
    return nil if fragment.nil? || fragment["values"].nil?
    return fragment unless @i_am_a_topic_page_finder

    fragment["values"] = fragment["values"].reject do |value|
      %w[level_one_taxon level_two_taxon].include? value["parameter_key"]
    end

    fragment["values"].count.zero? ? nil : fragment
  end
end

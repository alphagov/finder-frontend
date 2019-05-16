class AdvancedSearchResultSetPresenter < ResultSetPresenter
  include AdvancedSearchParams

  def to_hash
    super
      .merge(applied_filters: selected_filter_descriptions)
        .except(:atom_url)
  end

  def documents
    results.each_with_index.map do |result, index|
      metadata = metadata_presenter_class.new(result.metadata).present
      {
        document: AdvancedSearchResultPresenter.new(result, metadata).to_hash,
        document_index: index + 1,
      }
    end
  end

  def any_filters_applied?
    finder.taxon.present? || finder.content_purpose_subgroups.any?
  end

  def subgroups_as_sentence
    "#{subgroup_facet.preposition} #{finder.content_purpose_subgroups.to_sentence.downcase}"
  end

  def fragment_to_s(fragment)
    values = fragment['values'].map { |value|
      html_escape(value['label'])
    }

    if fragment['type'] == "text"
      values.to_sentence(two_words_connector: ' or ', last_word_connector: ' or ').downcase
    elsif fragment['type'] == "date"
      values.to_sentence(two_words_connector: ' and ')
    end
  end

  def applied_filters_or_all_subgroups
    cleanup_whitespace(
      if selected_filter_descriptions.blank?
        subgroups_as_sentence
      elsif !subgroup_facet.has_filters?
        [subgroups_as_sentence, filters_to_sentence(selected_filter_descriptions)].to_sentence
      else
        [filters_to_sentence(selected_filter_descriptions)].to_sentence
      end
    )
  end

  def subgroup_facet
    finder.facets.find { |f| f.key == SUBGROUP_SEARCH_FILTER }
  end

  def cleanup_whitespace(sentence)
    sentence.strip.gsub(/  /, " ")
  end

private

  def filters_to_sentence(filters)
    filters.flat_map { |filter| filter }.map { |filter| "#{filter[:preposition].downcase} #{filter[:text]}" }.join(' ')
  end
end

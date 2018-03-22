class AdvancedSearchResultSetPresenter < ResultSetPresenter
  include AdvancedSearchParams

  def to_hash
    super
      .merge(applied_filters: applied_filters_or_all_subgroups)
      .except(:atom_url)
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
      if describe_filters_in_sentence.blank?
        subgroups_as_sentence
      elsif subgroup_facet.value.blank?
        [
          subgroups_as_sentence,
          describe_filters_in_sentence
        ].to_sentence
      else
        describe_filters_in_sentence
      end
    )
  end

  def subgroup_facet
    finder.facets.find { |f| f.key == SUBGROUP_SEARCH_FILTER }
  end

  def cleanup_whitespace(sentence)
    sentence.strip.gsub(/  /, " ")
  end
end

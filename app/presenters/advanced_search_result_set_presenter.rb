class AdvancedSearchResultSetPresenter < ResultSetPresenter
  def to_hash
    super.merge(applied_filters: applied_filters_or_all_subgroups)
  end

  def any_filters_applied?
    finder.taxon.present? || finder.content_purpose_subgroups.any?
  end

  def subgroups_as_sentence
    finder.content_purpose_subgroups.to_sentence.downcase
  end

  def fragment_to_s(fragment)
    values = fragment['values'].map { |value|
      html_escape(value['label'])
    }

    if fragment['type'] == "text"
      values.to_sentence(two_words_connector: ' or ', last_word_connector: ' or ')
    elsif fragment['type'] == "date"
      values.to_sentence(two_words_connector: ' and ')
    end
  end

  def applied_filters_or_all_subgroups
    if describe_filters_in_sentence.blank?
      subgroups_as_sentence
    else
      describe_filters_in_sentence
    end
  end
end

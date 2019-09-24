class AtomPresenter
  def initialize(content_item, result_set, facet_tags)
    @content_item = content_item
    @filter_descriptions = facet_tags.selected_filter_descriptions
    @result_set = result_set
  end

  def title
    return "#{content_item.title} #{filters_applied.join(' ')}" if filters_applied.present?

    content_item.title
  end

  def filters_applied
    @filters_applied ||= filter_descriptions.map { |filters|
      filters.map { |filter| "#{filter[:preposition].downcase} #{filter[:text]}" }
    }.flatten
  end

  def entries
    result_set.documents
    .reject { |d| d.public_timestamp.blank? && d.release_timestamp.blank? }
    .map { |d| EntryPresenter.new(d, content_item.show_summaries?) }
  end

  def updated_at
    entries.first.updated_at
  end

private

  attr_reader :content_item, :result_set, :filter_descriptions
end

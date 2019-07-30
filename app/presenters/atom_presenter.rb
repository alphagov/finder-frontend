class AtomPresenter
  def initialize(finder_presenter, results, facet_tags)
    @finder_presenter = finder_presenter
    @results = results
    @filter_descriptions = facet_tags.selected_filter_descriptions
  end

  def title
    return "#{finder_presenter.name} #{filters_applied.join(' ')}" if filters_applied.present?

    finder_presenter.name
  end

  def filters_applied
    @filters_applied ||= filter_descriptions.map { |filters|
      filters.map { |filter| "#{filter[:preposition].downcase} #{filter[:text]}" }
    }.flatten
  end

  def entries
    finder_presenter.results.documents
    .reject { |d| d.public_timestamp.blank? && d.release_timestamp.blank? }
    .map { |d| EntryPresenter.new(d) }
  end

  def updated_at
    entries.first.updated_at
  end

private

  attr_reader :finder_presenter, :results, :filter_descriptions
end

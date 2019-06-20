# typed: true
class AtomPresenter
  def initialize(finder, results, facet_tags)
    @finder = finder
    @results = results
    @filter_descriptions = facet_tags.selected_filter_descriptions
  end

  def title
    return "#{finder.name} #{filters_applied.join(' ')}" if filters_applied.present?

    finder.name
  end

  def filters_applied
    @filters_applied ||= filter_descriptions.map { |filters|
      filters.map { |filter| "#{filter[:preposition].downcase} #{filter[:text]}" }
    }.flatten
  end

  def entries
    finder.results.documents
    .reject { |d| d.public_timestamp.blank? && d.release_timestamp.blank? }
    .map { |d| EntryPresenter.new(d) }
  end

  def updated_at
    entries.first.updated_at
  end

private

  attr_reader :finder, :results, :filter_descriptions
end

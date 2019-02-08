class AtomPresenter
  def initialize(finder, results)
    @finder = finder
    @results = results
  end

  def title
    return "#{finder.name} #{filters_applied.join(' ')}" if filters_applied.present?

    finder.name
  end

  def filters_applied
    @filters_applied ||= results.selected_filter_descriptions.map { |filters|
      filters.map { |filter| "#{filter[:preposition].downcase} #{filter[:text]}" }
    }.flatten
  end

  def entries
    finder.results.documents
    .reject { |d| d.public_timestamp.blank? }
    .map { |d| EntryPresenter.new(d) }
  end

  def updated_at
    entries.first.updated_at
  end

private

  attr_reader :finder, :results
end

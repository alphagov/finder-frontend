class AtomPresenter
  def initialize(finder)
    @finder = finder
  end

  def title
    finder.name
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

  attr_reader :finder
end

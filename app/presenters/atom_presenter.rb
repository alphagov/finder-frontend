class AtomPresenter

  def initialize(finder)
    @finder = finder
  end

  def title
    finder.name
  end

  def entries
    finder.results.documents
  end

  def updated_at
    DateTime.parse(entries.first.last_update)
  end

private
  attr_reader :finder

end

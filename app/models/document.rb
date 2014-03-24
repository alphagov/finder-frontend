class Document
  attr_reader :title, :slug

  def initialize(attrs)
    @title = attrs[:title]
    @slug = attrs[:slug]

    @attrs = attrs.except(:title, :slug)
  end

  def metadata
    tag_metadata + date_metadata
  end

  def to_partial_path
    'document'
  end

  def url
    "/#{slug}"
  end

private

  def date_metadata
    ['opened_date', 'closed_date'].map do |key|
      {
        name: key.humanize,
        value: @attrs[key],
        type: 'date'
      }
    end
  end

  def tag_metadata
    ['case_type', 'case_state', 'market_sector', 'outcome_type'].map do |key|
      {
        name: key.humanize,
        value: @attrs[key]['label'],
        type: 'text'
      }
    end
  end
end

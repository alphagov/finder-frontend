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
    keys = ['opened_date', 'closed_date'].select do |key|
      @attrs.fetch(key, false).present?
    end

    keys.map do |key|
      {
        name: key.humanize,
        value: @attrs[key],
        type: 'date'
      }
    end
  end

  def tag_metadata
    keys = ['case_type', 'case_state', 'market_sector', 'outcome_type'].select do |key|
      @attrs.fetch(key, {}).fetch('label', false).present?
    end

    keys.map do |key|
      {
        name: key.humanize,
        value: @attrs[key]['label'],
        type: 'text'
      }
    end
  end
end

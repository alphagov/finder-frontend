class SortOptionPresenter
  attr_reader :value, :key, :label

  def initialize(label: label, key: key, default: false)
    @label = label
    @value = label.parameterize
    @key = key
    @default = default
  end

  def default?
    default.present? && default
  end

  def relevance?
    RELEVANCE_OPTION_TYPES.include?(key)
  end

  def to_select_format
    [ label, value, tracking_attributes ]
  end

private

  attr_reader :default

  RELEVANCE_OPTION_TYPES = %w(relevance -relevance).freeze

  def tracking_attributes
    {
      'data-track-category' => 'dropDownClicked',
      'data-track-action' => 'clicked',
      'data-track-label' => label
    }
  end
end

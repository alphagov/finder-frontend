class SortOptionPresenter
  attr_reader :value, :key, :label

  def initialize(label:, key:, value: nil, default: false, disabled: false, selected: false)
    @label = label
    @value = value || label.parameterize
    @key = key
    @default = default
    @disabled = disabled
    @selected = selected
  end

  def default?
    default.present? && default
  end

  def to_hash
    {
      label:,
      value:,
      data_ga4_track_label: label,
      selected:,
      disabled:,
    }
  end

  def to_radio_option
    return nil if disabled

    {
      value:,
      text: label,
      checked: selected,
    }
  end

private

  attr_reader :default, :selected, :disabled
end

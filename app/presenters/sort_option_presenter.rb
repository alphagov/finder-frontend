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
      data_track_category: "dropDownClicked",
      data_track_action: "clicked",
      data_track_label: label,
      selected:,
      disabled:,
    }
  end

private

  attr_reader :default, :selected, :disabled
end

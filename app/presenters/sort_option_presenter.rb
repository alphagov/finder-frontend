class SortOptionPresenter
  attr_reader :value, :key, :label

  def initialize(label:, value: nil, key:, default: false, disabled: false, selected: false)
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
      label: label,
      value: value,
      data_track_category: "dropDownClicked",
      data_track_action: "clicked",
      data_track_label: label,
      selected: selected,
      disabled: disabled,
    }
  end

private

  attr_reader :default, :selected, :disabled

  def tracking_attributes
    {
      "data-track-category" => "dropDownClicked",
      "data-track-action" => "clicked",
      "data-track-label" => label,
    }
  end
end

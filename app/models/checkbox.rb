class Checkbox
  def initialize(checkbox)
    @checkbox = checkbox
  end

  def value
    checkbox["value"]
  end

  def label
    checkbox["label"]
  end

  def checkbox_label
    checkbox["checkbox_label"] || label
  end

  def id
    "checkbox_facet-#{label}_#{value}"
  end

  def data
    {
        track_category: "filterClicked",
        track_action: "checkboxFacet",
        track_label: label,
        module: "track-click"
    }
  end

private

  attr_accessor :checkbox
end

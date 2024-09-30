require "spec_helper"

describe "Filter section component", type: :view do
  def component_name
    "filter_section"
  end

  def render_component(locals)
    render "components/#{component_name}", locals
  end

  it "raises an error if heading_text option is omitted" do
    expect { render_component({}) }.to raise_error(/heading_text/)
  end

  it "renders a filter section that is closed" do
    render_component({ heading_text: "heading" })

    assert_select ".app-c-filter-section", count: 1
    assert_select ".app-c-filter-section[open=open]", false
  end

  it "renders a filter section that is open when open option is true" do
    render_component({ heading_text: "heading", open: true })

    assert_select ".app-c-filter-section[open=open]"
  end

  it "sets the heading text" do
    render_component({ heading_text: "section heading" })

    assert_select ".app-c-filter-section__summary-heading", text: "section heading"
  end

  it "adds the visually hidden heading prefix if given" do
    render_component({ heading_text: "section heading", visually_hidden_heading_prefix: "Filter by" })

    assert_select ".app-c-filter-section__summary-heading", include: "section heading"
    assert_select ".app-c-filter-section__summary-heading .govuk-visually-hidden", text: "Filter by"
  end

  it "set section heading text to different value to default renders correct heading level" do
    render_component({ heading_text: "section heading", heading_level: 3 })

    assert_select "h3.app-c-filter-section__summary-heading", count: 1
  end

  it "set section status text" do
    render_component({ heading_text: "heading", status_text: "1 selected" })

    assert_select ".app-c-filter-section__summary-status", text: "1 selected"
  end

  it "does not render status text when none supplied" do
    render_component({ heading_text: "heading" })

    assert_select ".app-c-filter-section__summary-status", false
  end

  it "renders ga4 tracking attributes to open/close button element" do
    button_event_attributes = {
      "ga4-expandable": "true",
      "ga4-event": {
        "event-name": "select_content",
        "type": "finder",
      },
    }

    heading_text = "Filter"

    render_component(heading_text:, data: button_event_attributes.to_json)

    assert_select ".app-c-filter-section summary[data-ga4-expandable]", true
    assert_select ".app-c-filter-section summary[data-ga4-event]", data: button_event_attributes.to_json
    assert_select ".app-c-filter-section summary[data-ga4-event]", data: { section: heading_text, text: heading_text }
  end
end

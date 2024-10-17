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

  it "sets the heading text with a visually hidden prefix by default" do
    render_component({ heading_text: "section heading" })

    assert_select ".app-c-filter-section__summary-heading", text: /Filter by\s+section heading/
    assert_select ".app-c-filter-section__summary-heading .govuk-visually-hidden", text: "Filter by"
  end

  it "allows disabling the visually hidden heading prefix" do
    render_component({
      heading_text: "section heading",
      disable_visually_hidden_heading_prefix: true,
    })

    assert_select ".app-c-filter-section__summary-heading", text: "section heading"
    assert_select ".app-c-filter-section__summary-heading .govuk-visually-hidden", false
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

  it "renders ga4 tracking attributes to open/close summary element" do
    heading_text = "Filter"

    button_event_attributes = {
      event_name: "select_content",
      type: "finder",
      section: heading_text,
      text: heading_text,
      index_section: 0,
      index_section_count: 0,
    }

    render_component(heading_text:)

    assert_select ".app-c-filter-section summary[data-ga4-expandable]", true
    assert_select ".app-c-filter-section summary[data-ga4-event='#{button_event_attributes.to_json}']", true
  end
end

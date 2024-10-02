require "spec_helper"

describe "Filter summary component", type: :view do
  def component_name
    "filter_summary"
  end

  let(:filters) do
    [
      {
        label: "Filter 1",
        value: "Value 1",
        remove_href: "/remove_url",
        visually_hidden_prefix: "Remove filter",
      },
      {
        label: "Filter 2",
        value: "Value 2",
        remove_href: "/remove_url",
        visually_hidden_prefix: "Remove filter",
      },
      {
        label: "Filter 3",
        value: "Value that is so long that the styling needs to handle it correctly",
        remove_href: "/remove_url",
        visually_hidden_prefix: "Remove filter",
      },
    ]
  end

  def render_component(locals)
    render "components/#{component_name}", locals
  end

  it "does not render a filter summary when no filters array passed" do
    render_component({ heading_text: "Selected filters" })

    assert_select ".app-c-filter-summary", false
  end

  it "does not render a filter summary when empty filters array passed" do
    render_component({ heading_text: "Selected filters", filters: [] })

    assert_select ".app-c-filter-summary", false
  end

  it "renders correct number of filters with hidden accesibilty text" do
    render_component({ filters: })

    assert_select ".app-c-filter-summary__remove-filter-text", count: 3
    assert_select ".app-c-filter-summary__remove-filter-text .govuk-visually-hidden", text: "Remove filter"
  end

  it "renders a heading if supplied" do
    render_component({ heading_text: "Selected filters", filters: })

    assert_select ".app-c-filter-summary__heading", text: "Selected filters"
  end

  it "renders a clear all link if supplied" do
    render_component({ filters:, clear_all_href: "/url", clear_all_text: "Clear all" })

    assert_select ".app-c-filter-summary__clear-filters", count: 1
    assert_select ".app-c-filter-summary__clear-filters", href: "/url"
  end

  it "does not render a clear all link if one of text and href are omitted" do
    render_component({ filters:, clear_all_text: "Clear all" })

    assert_select ".app-c-filter-summary__clear-filters", false
  end

  it "set summary heading text to different value to default renders correct heading level" do
    render_component({ heading_text: "Selected filters", filters:, clear_all_href: "/url", heading_level: 4 })

    assert_select "h4.app-c-filter-summary__heading", count: 1
  end

  it "renders ga4 tracking attributes to remove links" do
    link_event_attributes = {
      event_name: "select_content",
      type: "finder",
      section: "Filter 1",
      action: "remove",
    }

    render_component(filters:, data: link_event_attributes.to_json)

    assert_select ".app-c-filter-summary__remove-filter[data-ga4-event='#{link_event_attributes.to_json}']"
  end

  it "renders ga4 tracking attributes to clear all link" do
    clear_all_text = "Clear all the things"
    clear_all_href = "#"
    link_event_attributes = {
      event_name: "select_content",
      type: "finder",
      text: clear_all_text,
      section: "Selected filters and sorting",
      action: "remove",
    }

    render_component(clear_all_text:, clear_all_href:, filters:, data: link_event_attributes.to_json)

    assert_select ".app-c-filter-summary__clear-filters[data-ga4-event='#{link_event_attributes.to_json}']"
  end
end

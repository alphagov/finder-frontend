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
        displayed_text: "Displayed text 1",
        remove_href: "/remove_url",
        visually_hidden_prefix: "Remove filter",
      },
      {
        label: "Filter 2",
        value: "Value 2",
        displayed_text: "Displayed text 21",
        remove_href: "/remove_url",
        visually_hidden_prefix: "Remove filter",
      },
      {
        label: "Filter 3",
        value: "Value that is so long that the styling needs to handle it correctly",
        displayed_text: "Displayed text 3",
        remove_href: "/remove_url",
        visually_hidden_prefix: "Remove filter",
      },
    ]
  end

  def render_component(locals)
    render "components/#{component_name}", locals
  end

  it "renders correct number of filters with hidden accesibilty text" do
    render_component({ filters: })

    assert_select ".app-c-filter-summary__remove-filter-text", count: 3
    assert_select ".app-c-filter-summary__remove-filter-text .govuk-visually-hidden", text: "Remove filter"
  end

  it "renders a different heading if supplied" do
    render_component({ heading_text: "My awesome filters", filters: })

    assert_select ".app-c-filter-summary__heading", text: "My awesome filters"
  end

  it "renders a clear all link if supplied" do
    render_component({ filters:, clear_all_href: "/url", clear_all_text: "Get rid of it all" })

    assert_select ".app-c-filter-summary__clear-filters", count: 1
    assert_select ".app-c-filter-summary__clear-filters", href: "/url", text: "Get rid of it all"
  end

  it "does not render a clear all link if href is omitted" do
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
      text: "Displayed text 1",
      section: "Filter 1",
      action: "remove",
    }

    render_component(filters:)

    assert_select ".app-c-filter-summary__remove-filter[data-ga4-event='#{link_event_attributes.to_json}']"
  end

  it "renders ga4 tracking attributes to clear all link" do
    clear_all_text = "Clear all the things"
    clear_all_href = "#"
    heading_text = "Selected filters"
    link_event_attributes = {
      event_name: "select_content",
      type: "finder",
      text: clear_all_text,
      section: heading_text,
      action: "remove",
    }

    render_component(heading_text: "Selected filters", clear_all_text:, clear_all_href:, filters:)

    assert_select ".app-c-filter-summary__clear-filters[data-ga4-event='#{link_event_attributes.to_json}']"
  end
end

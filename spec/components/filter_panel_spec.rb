require "spec_helper"

describe "Filter panel component", type: :view do
  def component_name
    "filter_panel"
  end

  def render_component(locals, &block)
    if block_given?
      render("components/#{component_name}", locals, &block)
    else
      render "components/#{component_name}", locals
    end
  end

  it "raises an error if button_text option is omitted" do
    expect { render_component({}) }.to raise_error(/button_text/)
  end

  it "raises an error if show_reset_link option is given without reset_link_href" do
    expect { render_component(button_text: "Filter", show_reset_link: true) }.to raise_error(/reset_link_href/)
  end

  it "renders the button with the correct text" do
    render_component(button_text: "Filtern und sortieren")

    assert_select ".app-c-filter-panel button", text: "Filtern und sortieren"
  end

  it "renders the result text as an h2 if given" do
    render_component(button_text: "Filter", result_text: "Lorem ipsum")

    assert_select ".app-c-filter-panel h2", text: "Lorem ipsum"
  end

  it "does not render an h2 if no result text is given" do
    render_component(button_text: "Filter")

    assert_select ".app-c-filter-panel h2", false
  end

  it "renders the passed block into the content area" do
    render_component(button_text: "Filter") do
      tag.p("Hello, world!")
    end

    assert_select ".app-c-filter-panel .app-c-filter-panel__content p", text: "Hello, world!"
  end

  it "does not render the content hidden to begin with" do
    render_component(button_text: "Filter")

    assert_select ".app-c-filter-panel[hidden]", false
  end

  it "respects the standard 'open' option" do
    render_component(button_text: "Filter", open: true)

    assert_select ".app-c-filter-panel[open=open]"
  end

  it "renders the submit button" do
    render_component(button_text: "Filter")

    assert_select ".app-c-filter-panel input.govuk-button.app-c-filter-panel__action.app-c-filter-panel__action--submit", value: "Apply filters"
  end

  it "renders the reset link if the show_reset_link option is given" do
    render_component(button_text: "Filter", show_reset_link: true, reset_link_href: "/reset")

    assert_select ".app-c-filter-panel a.govuk-link.govuk-link--no-visited-state.app-c-filter-panel__action.app-c-filter-panel__action--reset[href='/reset']", text: "Clear all filters"
  end

  it "does not render the reset link if the show_reset_link option is not given" do
    render_component(button_text: "Filter")

    assert_select ".app-c-filter-panel a", false
  end

  it "renders ga4 tracking attributes to open/close button element" do
    button_text = "Filter"

    button_event_attributes = {
      event_name: "select_content",
      type: "finder",
      section: button_text,
      text: button_text,
      index_section: 0,
      index_section_count: 4,
    }

    render_component(button_text:, data: button_event_attributes.to_json)

    assert_select ".app-c-filter-panel button[data-ga4-expandable]", true
    assert_select ".app-c-filter-panel button[data-ga4-event='#{button_event_attributes.to_json}']", true
  end

  it "renders ga4 tracking attributes to submit button element" do
    button_text = "Apply filters"

    button_event_attributes = {
      event_name: "select_content",
      type: "finder",
      text: button_text,
      section: "Filter and sort",
      action: "search",
      index_section: 0,
      index_section_count: 4,
    }

    render_component(button_text:, data: button_event_attributes.to_json)

    assert_select ".app-c-filter-panel__action--submit[data-ga4-event='#{button_event_attributes.to_json}']", true
  end
end

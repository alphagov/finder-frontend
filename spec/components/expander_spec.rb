require "spec_helper"

describe "expander", type: :view do
  def component_name
    "expander"
  end

  def render_component(locals, &block)
    if block_given?
      render("components/#{component_name}", locals, &block)
    else
      render "components/#{component_name}", locals
    end
  end

  it "renders nothing without passed content" do
    assert_empty render_component({})
  end

  it "shows the given title and content" do
    render_component(title: "Some title") do
      "This is more info"
    end

    assert_select ".app-c-expander"
    assert_select ".app-c-expander__title", text: "Some title"
    assert_select ".app-c-expander__content", text: "This is more info"
  end

  it "sets open on load correctly" do
    render_component(title: "Some title", open_on_load: true) do
      "This is more info"
    end

    assert_select ".app-c-expander[data-open-on-load='true']"
  end

  it "sets a margin bottom" do
    render_component(title: "Some title", margin_bottom: 9) do
      "This is more info"
    end

    assert_select '.app-c-expander.govuk-\!-margin-bottom-9'
  end

  it "accepts button data attributes" do
    button_attrs = {
      ga4_expandable: "true",
      ga4_event: {
        event_name: "select_content",
        type: "finder",
      },
    }

    render_component(title: "Some title", button_data_attributes: button_attrs) do
      "This is more info"
    end

    assert_select ".app-c-expander[data-button-data-attributes='#{button_attrs.to_json}']"
  end
end

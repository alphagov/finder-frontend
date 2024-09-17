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
end

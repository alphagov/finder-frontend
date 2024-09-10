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

  it "raises an error if button_text argument is omitted" do
    expect { render_component(result_count: 42) }.to raise_error(/button_text/)
  end

  it "raises an error if result_count argument is omitted" do
    expect { render_component(button_text: "Oops") }.to raise_error(/result_count/)
  end

  it "renders the button with the correct text" do
    render_component(button_text: "Filtern und sortieren", result_count: 42)

    assert_select ".app-c-filter-panel button", text: "Filtern und sortieren"
  end

  it "renders the correct result count heading for a single result" do
    render_component(button_text: "Filter", result_count: 1)

    assert_select ".app-c-filter-panel h2", text: "1 result"
  end

  it "renders the correct result count heading for a small number" do
    render_component(button_text: "Filter", result_count: 84)

    assert_select ".app-c-filter-panel h2", text: "84 results"
  end

  it "renders the correct result count heading for a large number" do
    render_component(button_text: "Filter", result_count: 12_345_678)

    assert_select ".app-c-filter-panel h2", text: "12,345,678 results"
  end
end

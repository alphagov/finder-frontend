require "spec_helper"

describe "Filter section component", type: :view do
  def component_name
    "filter_section"
  end

  def render_component(locals)
    render "components/#{component_name}", locals
  end

  it "raises an error if status_title option is omitted" do
    expect { render_component({}) }.to raise_error(/status_title/)
  end

  it "is closed by default" do
    render_component({status_title: "title"})

    assert_select ".app-c-filter-panel__section-details[open=open]", count: 0
  end

  it "is open by default with open option set to true" do
    render_component({status_title: "title", open: true})

    assert_select ".app-c-filter-panel__section-details[open=open]"
  end
end

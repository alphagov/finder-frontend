require 'spec_helper'

describe 'components/_option-select.html.erb', type: :view do
  def component_name
    'option-select'
  end

  def render_component(component_arguments)
    render partial: "components/#{component_name}", locals: component_arguments
  end

  def option_key
    "key"
  end

  def option_select_arguments
    {
      key: option_key,
      title: "Market sector",
      options_container_id: "list-of-sectors",
      options: [
        {
          value: "aerospace",
          label: "Aerospace",
          id: "aerospace"
        },
        {
          value: "value",
          label: "Label",
          id: "ID"
        }
      ]
    }
  end

  it "renders a heading for the option select box containing the title" do
    render_component(option_select_arguments)
    expect(rendered).to have_selector(".option-select-label", text: 'Market sector')
  end

  it "renders a container with the id passed in" do
    render_component(option_select_arguments)
    expect(rendered).to have_selector("\#list-of-sectors.options-container")
  end

  it "renders a list of checkboxes" do
    render_component(option_select_arguments)

    expect_label_and_checkbox("Aerospace", "aerospace", "aerospace")
    expect_label_and_checkbox("Label", "ID", "value")
  end

  it "can set checkboxes to be pre-selected" do
    arguments = option_select_arguments
    arguments[:options][0][:checked] = true
    arguments[:options][1][:checked] = true
    render_component(arguments)

    expect_label_and_checked_checkbox("Aerospace", "aerospace", "aerospace")
    expect_label_and_checked_checkbox("Label", "ID", "value")
  end

  it "can indicate that the checkboxes control content displayed via aria-controls-id" do
    arguments = option_select_arguments
    arguments[:aria_controls_id] = "aria-controls-id"
    render_component(arguments)

    expect(rendered).to have_selector '[data-input-aria-controls="aria-controls-id"]', count: 1
  end

  it "can begin with the options box closed on load" do
    arguments = option_select_arguments
    arguments[:closed_on_load] = true
    render_component(arguments)

    expect(rendered).to have_selector('.app-c-option-select[data-closed-on-load="true"]')
  end

  def expect_label_and_checked_checkbox(label, id, value)
    expect_label_and_checkbox(label, id, value, true)
  end

  def expect_label_and_checkbox(label, id, value, checked = false)
    expected_name = "[name='#{option_key}[]']"
    expected_id = "[id='#{option_key}-#{id}']"
    expected_value = "[value='#{value}']"
    expected_checked = checked ? "[checked='checked']" : ""

    expect(rendered).to have_selector expected_name
    expect(rendered).to have_selector expected_id
    expect(rendered).to have_selector expected_value

    expect(rendered).to have_selector "label[for='#{option_key}-#{id}']", text: label
    expect(rendered).to have_selector "input[type='checkbox']#{expected_name}#{expected_id}#{expected_value}#{expected_checked}"
  end
end

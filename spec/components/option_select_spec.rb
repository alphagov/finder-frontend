require 'govuk_component_test_helper'

class OptionSelectTestCase < ComponentTestCase
  def component_name
    "option_select"
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

  test "renders a heading for the option select box containing the title" do
    render_component(option_select_arguments)
    assert_select ".option-select-label", text: "Market sector"
  end

  test "renders a container with the id passed in" do
    render_component(option_select_arguments)
    assert_select "\#list-of-sectors.options-container"
  end

  test "renders a list of checkboxes" do
    render_component(option_select_arguments)

    assert_label_and_checkbox("Aerospace", "aerospace", "aerospace")
    assert_label_and_checkbox("Label", "ID", "value")
  end

  test "can set checkboxes to be pre-selected" do
    arguments = option_select_arguments
    arguments[:options][0][:checked] = true
    arguments[:options][1][:checked] = true
    render_component(arguments)

    assert_label_and_checked_checkbox("Aerospace", "aerospace", "aerospace")
    assert_label_and_checked_checkbox("Label", "ID", "value")
  end

  test "can indicate that the checkboxes control content displayed via aria-controls-id" do
    arguments = option_select_arguments
    arguments[:aria_controls_id] = "aria-controls-id"
    render_component(arguments)

    assert_select '[data-input-aria-controls="aria-controls-id"]', count: 1
  end

  test "can begin with the options box closed on load" do
    arguments = option_select_arguments
    arguments[:closed_on_load] = true
    render_component(arguments)

    assert_select '.govuk-option-select[data-closed-on-load="true"]'
  end

  def assert_label_and_checked_checkbox(label, id, value)
    assert_label_and_checkbox(label, id, value, true)
  end

  def assert_label_and_checkbox(label, id, value, checked = false)
    expected_name = "[name='#{option_key}[]']"
    expected_id = "[id='#{option_key}-#{id}']"
    expected_value = "[value='#{value}']"
    expected_checked = checked ? "[checked='checked']" : ""

    assert_select expected_name
    assert_select expected_id
    assert_select expected_value

    assert_select "label[for='#{option_key}-#{id}']", text: label
    assert_select "input[type='checkbox']#{expected_name}#{expected_id}#{expected_value}#{expected_checked}"
  end
end

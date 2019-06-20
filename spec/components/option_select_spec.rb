# typed: false
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

  def option_select_with_tracking_arguments
    {
      key: option_key,
      title: "Market sector",
      options_container_id: "list-of-sectors",
      options: [
        {
          value: "aerospace",
          label: "Aerospace",
          id: "aerospace",
          data_attributes: {
            track_category: "filterClicked",
            track_action: "Market Sector",
            track_label: "aerospace",
            track_options: {
              dimension28: 1
            }
          }
        },
        {
          value: "value",
          label: "Label",
          id: "ID",
          data_attributes: {
            track_category: "filterClicked",
            track_action: "Market Sector",
            track_label: "value",
            track_options: {
              dimension28: 2
            }
          }
        }
      ]
    }
  end

  it "renders a heading for the option select box containing the title" do
    render_component(option_select_arguments)
    expect(rendered).to have_selector(".app-c-option-select__title", text: 'Market sector')
  end

  it "renders a container with the id passed in" do
    render_component(option_select_arguments)
    expect(rendered).to have_selector("\#list-of-sectors.app-c-option-select__container")
  end

  it "can begin with the options box closed on load" do
    arguments = option_select_arguments
    arguments[:closed_on_load] = true
    render_component(arguments)

    expect(rendered).to have_selector('.app-c-option-select[data-closed-on-load="true"]')
  end

  it "can show a filter control" do
    arguments = option_select_arguments
    arguments[:show_filter] = true
    render_component(arguments)

    expect(rendered).to have_selector('.app-c-option-select[data-filter-element]')
    expect(rendered).to have_selector('.app-c-option-select__count')
  end

  it "does not show a filter control" do
    arguments = option_select_arguments
    arguments[:show_filter] = false
    render_component(arguments)

    expect(rendered).to have_no_selector('.app-c-option-select .gem-c-input[name="option-select-filter"]')
    expect(rendered).to have_no_selector('.app-c-option-select__count')
  end

  it "adds alternative styling" do
    arguments = option_select_arguments
    arguments[:expander_style] = true
    render_component(arguments)

    expect(rendered).to have_selector('.app-c-option-select.app-c-option-select--expander')
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

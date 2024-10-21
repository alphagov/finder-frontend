module InputHelper
  def date_input(id, display_name, value, hint: nil, error_message: nil, legend_suffix: nil)
    legend_text = [display_name, legend_suffix].compact.join(" ")
    value ||= {}
    container_data_attrs = { ga4_section: legend_text }

    if error_message
      container_data_attrs[:module] = "ga4-auto-tracker"
      container_data_attrs[:ga4_auto] = {
        event_name: "form_error",
        type: "finder",
        text: error_message,
        section: legend_text,
        action: "error",
        tool_name: "Search GOV.UK",
      }
    end

    tag.div(data: container_data_attrs) do
      render(
        "govuk_publishing_components/components/date_input",
        id:,
        name: id,
        legend_text:,
        hint:,
        error_message:,
        items: [
          {
            name: "day",
            width: 2,
            value: value[:day],
          },
          {
            name: "month",
            width: 2,
            value: value[:month],
          },
          {
            name: "year",
            width: 4,
            value: value[:year],
          },
        ],
      )
    end
  end
end

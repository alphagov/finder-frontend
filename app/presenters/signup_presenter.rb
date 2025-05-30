class SignupPresenter
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::CaptureHelper
  attr_reader :content_item, :params

  def initialize(content_item, params)
    @content_item = content_item
    @params = params
  end

  def page_title
    "#{name} emails"
  end

  def name
    content_item["title"]
  end

  def beta?
    content_item["details"]["beta"]
  end

  def document_type
    content_item["document_type"]
  end

  def schema_name
    content_item["schema_name"]
  end

  def email_filter_by
    content_item.dig("details", "email_filter_by")
  end

  def can_modify_choices?
    choices? && choices_formatted.any? && email_filter_by != "all_selected_facets"
  end

  def choices?
    email_filter_facets.present?
  end

  def choices
    email_filter_facets
  end

  def choices_formatted
    @choices_formatted ||= facets_with_choices.map { |choice|
      {
        label: choice["facet_name"],
        value: choice["facet_id"],
        checked: choice["prechecked"],
        items: choice["facet_choices"].map do |facet_choice|
          {
            name: "filter[#{choice['facet_id']}][]",
            label: facet_choice["radio_button_name"],
            value: facet_choice["key"],
            checked: facet_choice["prechecked"] || selected_choices.fetch(choice["facet_id"], []).include?(facet_choice["key"]),
          }
        end,
      }
    }.compact
  end

private

  def facets_with_choices
    choices.select do |choice|
      choice["facet_choices"] && choice["facet_choices"].any?
    end
  end

  def selected_choices
    choices.each_with_object({}) do |choice, hash|
      key = choice["facet_id"]
      next unless params.key?(key)

      hash[choice["facet_id"]] = Array(params[key])
    end
  end

  def email_filter_facets
    content_item["details"].fetch("email_filter_facets", [])
  end
end

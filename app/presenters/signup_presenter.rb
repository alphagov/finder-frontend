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

  def body
    content_item["description"]
  end

  def beta?
    content_item["details"]["beta"]
  end

  def email_filter_by
    content_item.dig("details", "email_filter_by")
  end

  def can_modify_choices?
    choices? && choices_formatted.any? && email_filter_by != "all_selected_facets"
  end

  def hidden_choices
    hidden_choices = choices.map do |choice|
      if ignore_facet?(choice["facet_id"])
        choice["facet_choices"].map do |facet_choice|
          {
            name: "filter[#{choice['facet_id']}][]",
            value: facet_choice["key"],
          }
        end
      end
    end
    hidden_choices.flatten.compact
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
            value: facet_choice.fetch("content_id", nil) || facet_choice["key"],
            checked: facet_choice["prechecked"] || selected_choices.fetch(choice["facet_id"], []).include?(facet_choice["key"]),
          }
        end,
      }
    }.compact
  end

private

  def facets_with_choices
    choices.select { |choice|
      choice["facet_choices"] && choice["facet_choices"].any? && !ignore_facet?(choice["facet_id"])
    }
  end

  def selected_choices
    facets_ids = choices.each_with_object({}) do |choice, hash|
      hash[choice["facet_id"].to_sym] = []
    end
    params.permit(facets_ids).to_h
  end

  def email_filter_facets
    content_item["details"].fetch("email_filter_facets", [])
  end

  def ignore_facet?(facet_id)
    %W(facet_groups).include?(facet_id)
  end
end

class SignupPresenter
  attr_reader :content_item, :params

  def initialize(content_item, params)
    @content_item = content_item
    @params = params
  end

  def page_title
    "#{name} emails"
  end

  def name
    content_item['title']
  end

  def body
    content_item['description']
  end

  def beta?
    content_item['details']['beta']
  end

  def choices?
    multiple_facet_choice_data.present? || single_facet_choice_data[0]["facet_choices"].present?
  end

  def choices
    multiple_facet_choice_data || single_facet_choice_data
  end

  def choices_formatted
    choices.map do |choice|
      {
        label: choice['facet_name'],
        value: choice['facet_id'],
        checked: choice['prechecked'],
        items: choice['facet_choices'].map do |facet_choice|
          {
            name: "filter[#{choice['facet_id']}][]",
            label: facet_choice['radio_button_name'],
            value: facet_choice['key'],
            checked: facet_choice['prechecked'] || selected_choices.fetch(choice['facet_id'], []).include?(facet_choice['key'])
          }
        end
      }
    end
  end

  def target
    "#"
  end

private

  def selected_choices
    facets_ids = choices.each_with_object({}) do |choice, hash|
      hash[choice['facet_id'].to_sym] = []
    end
    params.permit(facets_ids).to_h
  end

  def single_facet_choice_data
    [
      {
        "facet_id" => content_item['details']["email_filter_by"],
        "facet_name" => single_facet_name,
        "facet_choices" => content_item['details']["email_signup_choice"]
      }
    ]
  end

  def multiple_facet_choice_data
    content_item['details']["email_filter_facets"]
  end

  def single_facet_name
    email_filter_name = content_item["details"]["email_filter_name"]
    return nil unless email_filter_name

    (email_filter_name["plural"] || email_filter_name).capitalize
  end
end

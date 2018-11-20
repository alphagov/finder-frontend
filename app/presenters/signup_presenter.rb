class SignupPresenter
  attr_reader :content_item

  def initialize(content_item)
    @content_item = content_item
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

  def target
    "#"
  end

private

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
    content_item['details']["email_filter_name"]["plural"] || content_item['details']["email_filter_name"]
  end
end

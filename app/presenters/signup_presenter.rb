class SignupPresenter
  attr_reader :content_item

  def initialize(content_item)
    @content_item = content_item
  end

  def page_title
    "#{name} emails"
  end

  def name
    content_item.title
  end

  def body
    content_item.description
  end

  def beta?
    content_item.details.beta
  end

  def choices?
    choice_data.present?
  end

  def choices
    choice_data
  end

  def choice_name(choice)
    choice_data.copy[choice]["radio_button_name"]
  end

  def choice_body(choice)
    choice_data.copy[choice]["body"]
  end

  def target
    "#"
  end

private

  def choice_data
    content_item.details["email_signup_choice"]
  end
end

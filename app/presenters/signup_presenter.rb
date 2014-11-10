class SignupPresenter < Struct.new(:content_item)
  def page_title
    "#{name} emails"
  end

  def title
    "#{name} email alert subscription"
  end

  def name
    content_item.title
  end

  def body
    content_item.details["description"]
  end

  def choices?
    choice_data.present?
  end

  def choice_key
    choice_data.key
  end

  def choices
    choice_data.choices
  end

  def choice_name(choice)
    choice_data.copy[choice]["name"]
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

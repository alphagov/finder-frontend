class SignupPresenter < Struct.new(:schema_attributes)
  def page_title
    "#{name} emails"
  end

  def title
    "#{name} email alert subscription"
  end

  def name
    schema_attributes.fetch("name")
  end

  def body
    schema_attributes.fetch("email_signup_copy")
  end

  def target
    schema_attributes.fetch("email_signup_url")
  end
end

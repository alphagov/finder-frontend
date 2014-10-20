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

  def target
    "#"
  end
end

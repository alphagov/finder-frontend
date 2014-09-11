class SignupPresenter < Struct.new(:artefact)
  def page_title
    "#{name} emails"
  end

  def title
    "#{name} email alert subscription"
  end

  def name
    artefact.title
  end

  def body
    artefact.description
  end

  def target
    "#"
  end
end

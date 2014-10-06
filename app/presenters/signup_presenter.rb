class SignupPresenter

  def initialize(signup)
    @signup = signup
  end

  def page_title
    "#{name} emails"
  end

  def title
    "#{name} email alert subscription"
  end

  def name
    signup.title
  end

  def body
    signup.body
  end

  def target
    "#"
  end

private

  attr_reader(
    :signup,
  )
end

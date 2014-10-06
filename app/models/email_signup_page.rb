class EmailSignupPage

  def initialize(dependencies = {})
    @artefact = dependencies.fetch(:artefact)
  end

  def title
    artefact.title
  end

  def body
    artefact.details["description"]
  end

private

  attr_reader(
    :artefact,
  )

end

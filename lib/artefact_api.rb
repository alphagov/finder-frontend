class ArtefactAPI

  def initialize(dependencies = {})
    @content_api = dependencies.fetch(:content_api)
  end

  def get(slug)
    content_api.artefact(slug)
  end

private
  attr_reader(
    :content_api,
  )
end

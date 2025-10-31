class FilterParamsValidator
  def initialize(params)
    @params = params
  end

  def validate!
    # NOTE: The 'q' parameter is normalized to 'keywords' earlier (via ParamsCleaner),
    # so this validator only checks 'keywords'.
    unless @params.fetch(:keywords, "").is_a?(String)
      raise ActionController::BadRequest, "Invalid 'keywords' query parameter"
    end
  end
end

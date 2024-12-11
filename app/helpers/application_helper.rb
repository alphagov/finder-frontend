module ApplicationHelper
  def absolute_url_for(path)
    URI.join(Plek.new.website_root, path)
  end

  def search_component
    use_autocomplete = true unless ENV["GOVUK_DISABLE_SEARCH_AUTOCOMPLETE"]

    use_autocomplete ? "search_with_autocomplete" : "search"
  end
end

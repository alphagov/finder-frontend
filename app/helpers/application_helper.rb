module ApplicationHelper
  def absolute_url_for(path)
    URI.join(Plek.current.website_root, path)
  end
end

module ApplicationHelper
  def absolute_url_for(path)
    URI.join(Plek.new.website_root, path)
  end
end

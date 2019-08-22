class DevelopmentController < ApplicationController
  layout "development_layout"

  def index
    @rendered_pages = Services.rummager.search(filter_rendering_app: "finder-frontend", count: 1000, order: "title")["results"]
  end
end

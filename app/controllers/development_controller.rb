class DevelopmentController < ApplicationController
  layout "development_layout"

  def index
    rendered_pages = Services.rummager.search(filter_rendering_app: "finder-frontend", count: 1000, order: "title")["results"]
    @rendered_pages = (rendered_pages + pages_with_inverted_header).sort_by { |hsh| hsh["title"] }
  end

  def pages_with_inverted_header
    [
      {
        "title" => "News and communications (inverted)",
        "link" => "/search/news-and-communications?parent=%2Feducation&topic=c58fdadd-7743-46d6-9629-90bb3ccc4ef0",
      },
      {
        "title" => "Research and statistics (inverted)",
        "link" => "/search/research-and-statistics?topic=c58fdadd-7743-46d6-9629-90bb3ccc4ef0",
      },
    ]
  end
end

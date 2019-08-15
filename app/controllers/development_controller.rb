class DevelopmentController < ApplicationController
  layout "development_layout"

  # https://github.com/alphagov/content-tagger/blob/f917f70f33b97e8fc04b3ae953f4631f285f1c37/lib/data/find-eu-exit-guidance-dynamic-lists.yml#L2
  CHECKLIST_FACET_GROUP = "e6dc1c00-453a-4fac-96ec-66a2f11ae327".freeze

  def index
    @rendered_pages = Services.rummager.search(filter_rendering_app: "finder-frontend", count: 1000, order: "title")["results"]
  end

  def checklists
    @all_possible_checklist_items = Services.rummager.search(
      filter_facet_groups: [CHECKLIST_FACET_GROUP],
      count: 1000,
      order: "title",
      fields: %w[title link content_id],
    )["results"]
  end
end

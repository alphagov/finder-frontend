class FinderPresenter
  include ActionView::Helpers::FormOptionsHelper
  include ActionView::Helpers::UrlHelper

  attr_reader :content_item, :organisations, :values, :keywords, :links, :facets

  delegate :hide_facets_by_default,
           :show_summaries?,
           :document_noun,
           :default_order,
           :show_phase_banner?,
           :links,
           :phase_message,
           :phase,
           :filter,
           :logo_path,
           :related,
           :summary,
           :email_alert_signup,
           :description,
           :no_index?,
           :canonical_link?,
           :all_content_finder?,
           :eu_exit_finder?,
           :title,
           :base_path,
           :government?,
           :government_content_section, to: :content_item


  def initialize(content_item, facets, values = {})
    @content_item = content_item
    @organisations = content_item.links.fetch("organisations", [])
    @values = values
    @facets = facets
    @keywords = values["keywords"].presence
  end

  def filters
    facets.select(&:filterable?)
  end
end

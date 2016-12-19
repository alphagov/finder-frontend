class FinderPresenter
  include ActionView::Helpers::UrlHelper

  attr_reader :name, :slug, :organisations, :keywords, :values

  delegate :alpha_message,
           :beta_message,
           :default_order,
           :document_noun,
           :human_readable_finder_format,
           :filter,
           :logo_path,
           :summary,
           :pagination,
           to: :"content_item.details"

  def initialize(content_item, values = {})
    @content_item = content_item
    @name = content_item.title
    @slug = content_item.base_path
    @organisations = content_item.links.organisations
    @values = values
    facets.values = values
    @keywords = values["keywords"].presence
  end

  def alpha?
    content_item.phase == 'alpha'
  end

  def beta?
    content_item.phase == 'beta'
  end

  def email_alert_signup
    if content_item.links.email_alert_signup
      content_item.links.email_alert_signup.first
    end
  end

  def email_alert_signup_url
    if content_item.details.signup_link.present?
      content_item.details.signup_link
    else
      if email_alert_signup
        email_alert_signup.web_url
      end
    end
  end

  def facets
    @facets ||= FacetCollection.new(
      content_item.details.facets.map { |facet|
        FacetParser.parse(facet)
      }
    )
  end

  def filters
    facets.filters
  end

  def government?
    slug.starts_with?("/government")
  end

  def government_content_section
    slug.split('/')[2]
  end

  def metadata
    facets.metadata
  end

  def date_metadata_keys
    metadata.select { |f| f.type == "date" }.map(&:key)
  end

  def text_metadata_keys
    metadata.select { |f| f.type == "text" }.map(&:key)
  end

  def filter_sentence_fragments
    filters.map(&:sentence_fragment).compact
  end

  def show_summaries?
    content_item.details.show_summaries
  end

  def page_metadata
    metadata = {
      part_of: part_of,
      from: from,
      other: other,
    }

    metadata.reject { |_, links| links.blank? }
  end

  def related
    related = content_item.links.related || []
    related.sort_by(&:title)
  end

  def results
    @results ||= ResultSetParser.parse(
      content_item.details.results,
      content_item.details.total_result_count,
      self,
    )
  end

  def label_for_metadata_key(key)
    facet = metadata.find { |f| f.key == key }

    facet.short_name || facet.key.humanize
  end

  def display_key_for_metadata_key(key)
    case key
    when 'organisations'
      'title'
    else
      'label'
    end
  end

  def atom_feed_enabled?
    !default_order.present?
  end

  def atom_url
    ["#{slug}.atom", values.to_query].reject(&:blank?).join("?") if atom_feed_enabled?
  end

  def description
    content_item.description
  end

private

  attr_reader :content_item

  def part_of
    content_item.links.part_of || []
  end

  def organisations
    content_item.links.organisations || []
  end

  def people
    content_item.links.people || []
  end

  def working_groups
    content_item.links.working_groups || []
  end

  def from
    organisations + people + working_groups
  end

  def other
    if applicable_nations_html_fragment
      { "Applies to" => applicable_nations_html_fragment }
    end
  end

  def applicable_nations_html_fragment
    nation_applicability = content_item.details.nation_applicability
    if nation_applicability
      applies_to = nation_applicability.applies_to.map(&:titlecase)
      alternative_policies = nation_applicability.alternative_policies.map do |alternative|
        link_to(alternative.nation.titlecase, alternative.alt_policy_url, ({ rel: 'external' } if is_external?(alternative.alt_policy_url)))
      end
      if alternative_policies.any?
        "#{applies_to.to_sentence} (see policy for #{alternative_policies.to_sentence})".html_safe
      else
        applies_to.to_sentence
      end
    end
  end

  def is_external?(href)
    if host = URI.parse(href).host
      "www.gov.uk" != host
    end
  end
end

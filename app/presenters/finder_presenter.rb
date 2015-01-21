class FinderPresenter

  attr_reader :name, :slug, :document_noun, :document_type, :organisations, :keywords, :beta_message

  def initialize(content_item, values = {}, keywords = nil)
    @content_item = content_item
    @name = content_item.title
    @slug = content_item.base_path.gsub('/','')
    @document_noun = content_item.details.document_noun
    @document_type = content_item.details.document_type
    @organisations = content_item.links.organisations
    facets.values = values
    @keywords = keywords
    @beta_message = content_item.details.beta_message
  end

  def beta?
    content_item.details.beta
  end

  def email_alert_signup_enabled?
    content_item.details.email_signup_enabled
  end

  def email_alert_signup
    if content_item.links.email_alert_signup
      content_item.links.email_alert_signup.first
    else
      nil
    end
  end

  def email_alert_signup_url
    if content_item.details.signup_link.present?
      content_item.details.signup_link
    else
      email_alert_signup.web_url
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

  def metadata
    facets.metadata
  end

  def filter_sentence_fragments
    filters.map(&:sentence_fragment).compact
  end

  def show_summaries?
    content_item.details.show_summaries
  end

  def organisations
    content_item.links.organisations
  end

  def primary_organisation
    organisations.first
  end

  def related
    content_item.links.related
  end

  def results
    @results ||= ResultSet.get(
      self,
      search_params,
    )
  end

private
  attr_reader :content_item, :values

  def facet_search_params
    facets.values
  end

  def keyword_search_params
    if keywords
      { "keywords" => keywords }
    else
      {}
    end
  end

  def search_params
    facet_search_params.merge(keyword_search_params)
  end
end

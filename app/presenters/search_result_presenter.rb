class SearchResultPresenter

  include ActionView::Context
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::TranslationHelper
  include SpecialistDocumentsHelper
  include DateTimeHelper

  attr_reader :title, :slug, :formatted_metadata

  def initialize(search_result)
    @title = search_result.title
    @slug = search_result.slug
    @formatted_metadata = format_metadata(search_result.metadata)
  end

  def to_hash
    {
      title: title,
      slug: slug,
      metadata: formatted_metadata,
    }
  end

  def format_metadata(metadata)
    data = metadata.map do |datum|
      { html: document_metadata_attribute_html(datum[:name], datum[:type], datum[:value]) }
    end
    data
  end

  def  format_date_if_date(value, type)
    case type
    when "date"
      Date.parse(value).strftime("%d %B %Y")
    else
      value
    end
  end
end

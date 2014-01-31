module ApplicationHelper
  def finder_page_class(finder)
    ['finder-page', finder.slug].join(' ')
  end

  def document_metadata_for(document)
    content_tag(
      :dl,
      Array(document.metadata).map { |metadata_entry|
        [
          content_tag(:dt, metadata_entry[:name]),
          content_tag(:dd, document_metadata_value(metadata_entry[:value], metadata_entry[:type]))
        ].join
      }.join.html_safe
    )
  end

private
  def document_metadata_value(value, type)
    case type
    when "date"
      Date.parse(value).strftime("%d %B %Y")
    else
      value
    end
  end
end

module ApplicationHelper
  def finder_page_class(finder)
    ['finder-page', finder.slug].join(' ')
  end

  def document_metadata_value(value, type)
    case type
    when "date"
      Date.parse(value).strftime("%d %B %Y")
    else
      value
    end
  end
end

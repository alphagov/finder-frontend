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

  def input_checked(key, value)
    if facet_has_any_selected_values?(key)
      if params[key].is_a?(Array) && params[key].include?(value)
        ' checked="checked"'
      elsif params[key] == value
        ' checked="checked"'
      end
    end
  end

  def facet_has_any_selected_values?(key)
    params.has_key?(key)
  end

  def link_params_without_facet_value(key, value)
    new_params = params.dup
    if new_params[key].is_a? Array
      new_params[key] = new_params[key] - [value]
      new_params.delete(key) if new_params[key].empty?
    else
      new_params.delete(key)
    end
    new_params
  end

  def facet_values_sentence(facet)
    values = facet.selected_values.map { |value|
      content_tag(:strong, "#{value.label} #{link_to("×", url_for(link_params_without_facet_value(facet.key, value.value)))}".html_safe)
    }
    values.to_sentence(last_word_connector: ' and ')
  end
end

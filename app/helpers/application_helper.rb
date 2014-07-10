module ApplicationHelper
  def finder_page_class(finder)
    ['finder-page', finder.slug].join(' ')
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
end

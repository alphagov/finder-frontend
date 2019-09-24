module ApplicationHelper
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

  def absolute_url_for(path)
    URI.join(Plek.current.website_root, path)
  end

  def page_metadata(metadata)
    metadata.inject({}) do |memo, (type, data)|
      memo.merge(
        type => data.is_a?(Array) ? arr_to_links(data) : data,
      )
    end
  end

  def arr_to_links(arr)
    arr.map { |link|
      link_to(link["title"], link["web_url"])
    }
  end
end

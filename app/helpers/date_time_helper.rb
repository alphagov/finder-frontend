module DateTimeHelper

  def formatted_date_html(time_string)
    time = Time.zone.parse(time_string.to_s)
    html = content_tag(:time, l(time, format: :as_date), datetime: time.iso8601)
    html.html_safe
  end

end

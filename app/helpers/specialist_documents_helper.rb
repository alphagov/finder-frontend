module SpecialistDocumentsHelper

  def document_metadata_attribute_html(name, type, value)
    html = ""
    html << document_metadata_label_html(name, type)
    html << document_metadata_value_html(value, type)
    html.html_safe
  end

  def document_metadata_value_html(value, type)
    html = content_tag :dd, class: "metadata-#{type}-value" do
      type == "date" ? formatted_date_html(value) : value
    end
    html.html_safe
  end

  def document_metadata_label_html(name, type)
    html = content_tag :dt, class: "metadata-#{type}-label" do
      "#{name}:"
    end
    html.html_safe
  end

end

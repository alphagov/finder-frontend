class StatisticsMetadataPresenter < MetadataPresenter
  def present
    formatted_metadata =
      raw_metadata.map { |datum|
        case datum.fetch(:type)
        when "date"
          build_date_metadata(datum)
        when "text", "content_id"
          build_text_metadata(datum)
        end
      }
    select_date_key(formatted_metadata)
  end

private

  def select_date_key(metadata)
    multiple_date_fields? ? metadata.reject { |key| key[:label] == "Updated" } : metadata
  end

  def multiple_date_fields?
    raw_metadata.pluck(:name).include?("Release date")
  end
end

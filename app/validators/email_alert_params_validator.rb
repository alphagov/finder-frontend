class EmailAlertParamsValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, filter)
    unless filter.is_a? Hash
      record.errors[attribute] << "is not a Hash"
      return
    end

    if invalidly_formatted(filter.keys).any?
      record.errors[attribute] << "has some unprocessable filter keys"
    end

    if invalidly_formatted(filter.values.flatten).any?
      record.errors[attribute] << "has some unprocessable filter values"
    end
  end

private

  def invalidly_formatted(values)
    # Allow alphanumerics, hyphens, and some legacy special characters.
    values.reject { |val|
      val.to_s.match?(/\A[a-zA-Z0-9\-_]*\z/)
    }
  end
end

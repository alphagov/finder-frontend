class EmailAlertParamsValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, filter)
    unless filter.is_a? Hash
      record.errors.add(attribute, message: "is not a Hash")
      return
    end

    if invalidly_formatted(filter.keys).any?
      record.errors.add(attribute, message: "has some unprocessable filter keys")
    end

    if invalidly_formatted(filter.values.flatten).any?
      record.errors.add(attribute, message: "has some unprocessable filter values")
    end
  end

private

  def invalidly_formatted(values)
    # Allow alphanumerics, hyphens, and some legacy special characters.
    values.reject do |val|
      val.to_s.match?(/\A[a-zA-Z0-9\-_]*\z/)
    end
  end
end

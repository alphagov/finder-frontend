class DateValidator
  def initialize(query)
    @query = query
  end

  def validate_to_date
    query.errors.add(:to_date, error_message) if invalid_date?(to_date)
  end

  def validate_from_date
    query.errors.add(:from_date, error_message) if invalid_date?(from_date)
  end

  def date_errors_hash
    {
      date_type => {
        from: invalid_date?(from_date),
        to: invalid_date?(to_date),
      },
    }
  end

private

  attr_reader :query

  def from_date
    extract_date(:from)
  end

  def to_date
    extract_date(:to)
  end

  def extract_date(key)
    value = query.filter_params.dig(date_type, key)

    if value.respond_to?(:compact_blank)
      value.compact_blank
    else
      value
    end
  end

  # The date facet on search/all filters on public_timestamp, but the specialist
  # finders use a variety of different types. Error messages are
  # currently only implemented on search/all.

  def date_type
    :public_timestamp
  end

  def invalid_date?(user_input)
    user_input.present? && DateParser.new(user_input).parse.nil?
  end

  def error_message
    "Enter a date"
  end
end

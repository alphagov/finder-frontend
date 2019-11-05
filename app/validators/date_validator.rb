class DateValidator < ActiveModel::Validator
  def initialize(query)
    @query = query
  end

  def validate
    validate_from_date
    validate_to_date
  end

  def error_hash
    {
      from: invalid_date?(from_date),
      to:   invalid_date?(to_date),
    }
  end

private

  attr_reader :query

  def validate_from_date
    query.errors.add(:from_date, error_message) if invalid_date?(from_date)
  end

  def validate_to_date
    query.errors.add(:to_date, error_message) if invalid_date?(to_date)
  end

  def from_date
    query.filter_params.dig(date_type, :from)
  end

  def to_date
    query.filter_params.dig(date_type, :to)
  end

  # The date facet on search/all filters on public_timestamp, but the specialist
  # finders use a variety of different types. Error messages are
  # currently only implemented on search/all.

  def date_type
    :public_timestamp
  end

  def invalid_date?(user_input)
    user_input.present? && DateParser.parse(user_input).nil?
  end

  def error_message
    "Enter a real date"
  end
end

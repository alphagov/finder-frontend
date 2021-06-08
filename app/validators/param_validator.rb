class ParamValidator < ActiveModel::Validator
  def initialize(query)
    super()
    @query = query
  end

  def validate
    validate_from_date
    validate_to_date
  end

  def errors_hash
    {}.merge(date_errors)
  end

private

  attr_reader :query

  def date_errors
    date_validator.date_errors_hash
  end

  def validate_from_date
    date_validator.validate_from_date
  end

  def validate_to_date
    date_validator.validate_to_date
  end

  def date_validator
    DateValidator.new(query)
  end
end

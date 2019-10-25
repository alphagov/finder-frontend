class DateErrorsPresenter
  def initialize(date_hash = {})
    @to_date = date_hash.dig(:to)
    @from_date = date_hash.dig(:from)
  end

  def error_hash
    {
      from: show_date_error?(from_date),
      to:   show_date_error?(to_date),
    }
  end

  def present(date)
    error_message if show_date_error?(date)
  end

private

  attr_reader :from_date, :to_date

  def show_date_error?(date)
    date.present? && invalid_date?(date)
  end

  def invalid_date?(user_input)
    DateParser.parse(user_input).nil?
  end

  def error_message
    "Please enter a valid date"
  end
end

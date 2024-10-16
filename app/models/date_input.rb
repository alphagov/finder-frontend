# Represents a user's date input, either based on a raw string input or a day/month/year hash as
# resulting from the standard three-field date input, and allows converting between the two so both
# old and new UI can work with either format when they come through as query parameters.
class DateInput
  attr_reader :original_input, :date

  def initialize(original_input)
    @original_input = original_input
    @date = DateParser.new(original_input).parse
  end

  def to_param
    original_input
  end

  def to_iso8601
    date&.iso8601
  end

  # Converts the original input to a string suitable for use in the legacy UI plain text date field
  def to_str
    case original_input
    when Hash
      # e.g. 07/07/1989 (not GOV.UK standard date format, but the hint text we suggest to users)
      date&.strftime("%0d/%0m/%-Y") || ""
    when String
      original_input
    else
      ""
    end
  end

  def to_hash
    case original_input
    when Hash
      original_input
    when String
      return {} if date.nil?

      {
        day: date.day,
        month: date.month,
        year: date.year,
      }
    else
      {}
    end
  end
end

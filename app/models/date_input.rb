# Represents a user's date input, either based on a raw string input or a day/month/year hash as
# resulting from the standard three-field date input.
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
end

class DateParser
  def initialize(date_param)
    @date_param = date_param
  end

  def parse
    case date_param
    when String
      DateStringParser.new(date_param).parse
    when Hash
      DateHashParser.new(date_param).parse
    when nil
      nil
    else raise ArgumentError, "date_param must be a String, Hash, or nil"
    end
  end

private

  attr_reader :date_param
end

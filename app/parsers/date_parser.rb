class DateParser
  def initialize(date_param)
    @date_param = date_param
  end

  def parse
    DateStringParser.new.parse(date_param)
  end

private

  attr_reader :date_param
end

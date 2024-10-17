class DateStringParser
  INVALID_CHARACTERS = /[!@£$%^&*]/

  def initialize(date_string)
    @date_string = date_string
      .to_s
      .strip
      .gsub(INVALID_CHARACTERS, "")
    @chronic_date = try_parse_chronic_date
  end

  def parse
    return nil unless chronic_date

    Date.new(chronic_date.year, chronic_date.month, chronic_date.day)
  end

private

  attr_reader :date_string, :chronic_date

  def try_parse_chronic_date
    Chronic.parse(normalized_date_string, guess: :begin, endian_precedence: :little)
  rescue StandardError
    nil
  end

  # Chronic parsing has some edge cases where it behaves differently from how we want to parse
  # dates, so we need to pre-normalize the raw date string to account for these.
  def normalized_date_string
    case date_string
    when /^\d{4}$/
      # Chronic would parse four digit numbers (YYYY) as time rather than a year
      #   e.g. "2008" becomes "8:08pm"
      "01/01/#{date_string}"
    when /^\d{6}$/
      # Chronic would parse six digit numbers (DDMMYY) as time
      #   e.g. "010101" becomes "1:01:01am"
      date_string.gsub(/(\d{2})(\d{2})(\d{2})/, '\1/\2/\3')
    when /^\d{8}$/
      # Chronic refuses to parse eight digit numbers (DDMMYYYY) altogether
      #   e.g. "01012001" becomes nil
      date_string.gsub(/(\d{2})(\d{2})(\d{4})/, '\1/\2/\3')
    when /^\d+$/
      # Chronic can parse nonsensical numbers as time, whereas we want to ignore them
      #   e.g. "100" as "1:00am"
      nil
    when /^((\d+)[\s.]){1,2}(\d+)$/
      # Chronic refuses to parse spaces as date separators, and has bugs when full stops are used,
      # so convert them to slashes
      #   e.g. "01 01 2001" becomes nil, "21.09.99" becomes today
      date_string.gsub(/[\s.]/, "/")
    when /^(#{Date::MONTHNAMES.compact.join('|')})$/i
      # Chronic parses month names as being either in this year or next, whereas we have decided to
      # always have them in this year
      "01/#{date_string}/#{Date.current.year}"
    else
      date_string
    end
  end
end

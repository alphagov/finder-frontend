# typed: true
class DateParser
  def self.parse(date_string)
    date_string = date_string.to_s.strip

    # Catches if user inputs just year which Chronic would parse as a time. e.g. "2008" as "8:08pm"
    date_string = "01/01/#{date_string}" if date_string.match?(/^\d{4}$/)

    # Catches fully padded dates without delimiters, eg 01012001
    if date_string.match?(/^\d{8}$/)
      date_string = date_string.gsub(/(\d{2})(\d{2})(\d{4})/, '\1/\2/\3')
    end

    # Converts spaces or dots with slashes, eg 01.01.2001 to 01/01/2001
    date_string = date_string.gsub(/(\d+)[. ](\d+)[. ]/, '\1/\2/')

    date = Chronic.parse(date_string, guess: :begin, endian_precedence: :little)
    date.to_date if date
  end
end

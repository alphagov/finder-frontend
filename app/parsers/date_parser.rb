class DateParser
  def self.parse(date_string)
    date_string = date_string.to_s.strip

    # Catches if user inputs just year which Chronic would parse as a time. e.g. "2008" as "8:08pm"
    date_string = "01/01/#{date_string}" if date_string.match?(/^\d{4}$/)

    # Catches fully padded dates without delimiters, eg 01012001
    if date_string.match?(/^\d{8}$/)
      date_string = date_string.gsub(/(\d{2})(\d{2})(\d{4})/, '\1/\2/\3')
    end

    # Catches if user input could be a month name which chronic would parse as this year
    # for months prior to now, and next year for months ahead of now
    if date_string.match?(/^[a-zA-Z]*$/)
      guessed_date = Chronic.parse(date_string, guess: :begin)
      if guessed_date
        guessed_year = Chronic.parse(date_string, guess: :begin).year
        this_year = Time.now.year
        date =
          guessed_year != this_year ? guessed_date - 1.year : guessed_date
      end
    end

    # Converts spaces or dots with slashes, eg 01.01.2001 to 01/01/2001
    date_string = date_string.gsub(/(\d+)[. ](\d+)[. ]/, '\1/\2/')

    date ||= Chronic.parse(date_string, guess: :begin, endian_precedence: :little)
    date.to_date if date
  end
end

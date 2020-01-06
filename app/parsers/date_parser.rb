class DateParser
  def parse(date_string)
    date_string = date_string.to_s.strip

    if date_string.present?
      date_string =
        contains_invalid_characters?(date_string) ? " " : date_string

      date_string =
        numbers_only?(date_string) ? process_number_only_inputs(date_string) : date_string

      date_string =
        delimited_date?(date_string) ? process_delimited_dates(date_string) : date_string
    end

    if could_be_month_name?(date_string)
      date = process_month_name_inputs(date_string)
    end
    date ||=
      begin
        Chronic.parse(date_string, guess: :begin, endian_precedence: :little)
      rescue StandardError
        nil
      end
    Date.new(date.year, date.month, date.day) if date
  end

private

  def contains_invalid_characters?(date_string)
    chars =
      date_string.split("") & %w(! @ £ $ % ^ & *)
    chars.any?
  end

  def numbers_only?(date_string)
    date_string.match?(/^\d+$/)
  end

  def could_be_month_name?(date_string)
    date_string.match?(/^[a-zA-Z]*$/)
  end

  def delimited_date?(date_string)
    date_string.match?(/(\d+)[. ](\d+)[. ]/)
  end

  # Converts spaces or dots with slashes, eg 01.01.2001 to 01/01/2001
  def process_delimited_dates(date_string)
    date_string.gsub(/(\d+)[. ](\d+)[. ]/, '\1/\2/')
  end

  def process_number_only_inputs(date_string)
    case date_string.length
    when 4
    # Catches if user inputs just year which Chronic would parse as a time. e.g. "2008" as "8:08pm"
      "01/01/#{date_string}"
    when 8
    # Catches fully padded dates without delimiters, eg 01012001
      date_string.gsub(/(\d{2})(\d{2})(\d{4})/, '\1/\2/\3')
    when 6
    # Catches fully padded dates without delimiters with abreviated year, eg 010101
      date_string.gsub(/(\d{2})(\d{2})(\d{2})/, '\1/\2/\3')
    else
    # Catches if user inputs an incorrect number of digits, which Chronic would parse as a time. e.g
    # "100" as todays's date at 13:00, or "10011" as today's date at 13:00:11
      date_string.replace(" ")
    end
  end

  # Catches if user input could be a month name which chronic would parse as this year
  # for months prior to now, and next year for months ahead of now
  def process_month_name_inputs(date_string)
    guessed_date = Chronic.parse(date_string, guess: :begin)
    if guessed_date
      guessed_year = guessed_date.year
      this_year = Time.zone.now.year
      guessed_year != this_year ? guessed_date - 1.year : guessed_date
    end
  end
end

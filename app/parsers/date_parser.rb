class DateParser
  def self.parse(date_string)
    # Line below has been added to fix Ruby's parsing of 6 digits
    # This will be break in the year 2100 
    massaged_date = date_string.sub(/\A(\d{1,2})\/(\d{1,2})\/(\d{2})\z/, '\1/\2/20\3')
    Date.parse(massaged_date) rescue nil
  end
end

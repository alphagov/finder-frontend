require "spec_helper"

describe DateParser do
  # These dates have been chosen based on analytics from site search more info here: https://designpatterns.hackpad.com/Dates-vpx6XlVjIbE
  dates = { # Zero padded, full year, various delimiters
            "21/01/2002" => Date.new(2002, 1, 21),
            "21.01.2002" => Date.new(2002, 1, 21),
            "21-01-2002" => Date.new(2002, 1, 21),
            "21 01 2002" => Date.new(2002, 1, 21),
            "21012002" => Date.new(2002, 1, 21),

            # Zero padded, abbreviated year, various delimiters
            "21/01/14" => Date.new(2014, 1, 21),
            "21.01.14" => Date.new(2014, 1, 21),
            "21-01-14" => Date.new(2014, 1, 21),

            # Zero padded, abbreviated year, last century
            "21/01/99" => Date.new(1999, 1, 21),
            "21.01.99" => Date.new(1999, 1, 21),
            "21-01-99" => Date.new(1999, 1, 21),
            "21 01 99" => Date.new(1999, 1, 21),

            # Unpadded dates, various delimiters
            "21/1/2002" => Date.new(2002, 1, 21),
            "21-1-2002" => Date.new(2002, 1, 21),
            "21.1.2002" => Date.new(2002, 1, 21),
            "21 1 2002" => Date.new(2002, 1, 21),

            # Other dates that people have entered on site search
            "21st january 2014" => Date.new(2014, 1, 21),
            "21 January 2014" => Date.new(2014, 1, 21),
            "september 2014" => Date.new(2014, 9, 1),
            "2008" => Date.new(2008, 1, 1),
            "2004/6/1" => Date.new(2004, 6, 1),
            "09/2013" => Date.new(2013, 9, 1),
            "22 Sept 2014" => Date.new(2014, 9, 22),

            # Invalid date
            "31/15/14" => nil,

            # Dates should be interpretted as UK not US
            "01/11/2014" => Date.new(2014, 11, 1),

            # Future date
            "22/09/25" => Date.new(2025, 9, 22),

            # Blank dates
            "" => nil,
            nil => nil,
          }

  dates.each_pair do |input, expected|
    it "returns the correct date for #{input}" do
      expect(DateParser.parse(input)).to eql(expected)
    end
  end

  dates.each_pair do |input, expected|
    it "returns the correct date for #{input} with trailing whitespace" do
      expect(DateParser.parse("#{input} ")).to eql(expected)
    end
  end

  dates.each_pair do |input, expected|
    it "returns the correct date for #{input} with preceeding whitespace" do
      expect(DateParser.parse(" #{input}")).to eql(expected)
    end
  end

  it "handles dates without years correctly" do
    date_to_parse = "26 november"

    year = 2001

    # Expected date is the date we've given it with the year returned by stubbed time.now
    expected_date = Date.new(year, 11, 26)

    # Stub Time.now to a known date
    pretend_today = Time.zone.local(year, 3, 11)
    allow(Time).to receive(:now).and_return(pretend_today)


    expect(DateParser.parse(date_to_parse)).to eql(expected_date)
  end
end

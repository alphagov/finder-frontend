require "spec_helper"

describe DateParser do
  subject(:parsed_date) { described_class.new(input).parse }

  context "when given a string date" do
    # These dates have been chosen based on analytics from site search more info here: https://designpatterns.hackpad.com/Dates-vpx6XlVjIbE
    this_year = Time.zone.now.year
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
      "1234" => Date.new(1234, 1, 1),
      "2004/6/1" => Date.new(2004, 6, 1),
      "09/2013" => Date.new(2013, 9, 1),
      "22 Sept 2014" => Date.new(2014, 9, 22),
      "010101" => Date.new(2001, 1, 1),

      # Invalid dates that should raise an error
      "31/15/14" => nil,
      "1@" => nil,
      "20120" => nil,
      "1" => nil,
      "randomwords" => nil,
      "Britain First" => nil,
      "6   april    2018 to april 2018" => nil,

      # Dates should be interpretted as UK not US
      "01/11/2014" => Date.new(2014, 11, 1),

      # Future date
      "22/09/25" => Date.new(2025, 9, 22),

      # Blank dates
      "" => nil,
      nil => nil,

      # Months only
      "January" => Date.new(this_year, 1, 1),
      "February" => Date.new(this_year, 2, 1),
      "March" => Date.new(this_year, 3, 1),
      "April" => Date.new(this_year, 4, 1),
      "May" => Date.new(this_year, 5, 1),
      "June" => Date.new(this_year, 6, 1),
      "July" => Date.new(this_year, 7, 1),
      "August" => Date.new(this_year, 8, 1),
      "September" => Date.new(this_year, 9, 1),
      "October" => Date.new(this_year, 10, 1),
      "November" => Date.new(this_year, 11, 1),
      "December" => Date.new(this_year, 12, 1),
    }

    dates.each_pair do |date, expected|
      context "with date '#{date}'" do
        let(:input) { date }

        it { is_expected.to eql(expected) }

        context "with leading whitespace" do
          let(:input) { " #{date}" }

          it { is_expected.to eql(expected) }
        end

        context "with trailing whitespace" do
          let(:input) { "#{date} " }

          it { is_expected.to eql(expected) }
        end
      end
    end

    context "for dates without years" do
      let(:pretend_today) { Time.zone.local(2001, 3, 11) }
      let(:input) { "26 november" }

      before do
        allow(Time).to receive(:now).and_return(pretend_today)
      end

      it { is_expected.to eql(Date.new(2001, 11, 26)) }
    end
  end
end

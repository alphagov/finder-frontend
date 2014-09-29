require "spec_helper"

describe DateParser do

  context "8 digit date" do
    let(:date_string) { "22/09/2014" }

    subject(:parsed_date) { DateParser.parse(date_string) }
    specify {
      parsed_date.year.should == 2014
      parsed_date.month.should == 9
      parsed_date.day.should == 22
    }
  end

  context "6 digit date" do
    let(:date_string) { "22/09/14" }

    subject(:parsed_date) { DateParser.parse(date_string) }
    specify {
      parsed_date.year.should == 2014
      parsed_date.month.should == 9
      parsed_date.day.should == 22
    }
  end

  context "5 digit date" do
    let(:date_string) { "22/9/14" }

    subject(:parsed_date) { DateParser.parse(date_string) }
    specify {
      parsed_date.year.should == 2014
      parsed_date.month.should == 9
      parsed_date.day.should == 22
    }
  end

  context "non-numeric long date" do
    let(:date_string) { "22nd September 2014" }

    subject(:parsed_date) { DateParser.parse(date_string) }
    specify {
      parsed_date.year.should == 2014
      parsed_date.month.should == 9
      parsed_date.day.should == 22
    }
  end

  context "non-numeric short date" do
    let(:date_string) { "22 Sept 2014" }

    subject(:parsed_date) { DateParser.parse(date_string) }
    specify {
      parsed_date.year.should == 2014
      parsed_date.month.should == 9
      parsed_date.day.should == 22
    }
  end

  context "false date value" do
    let(:date_string) { "31/15/14" }

    subject(:parsed_date) { DateParser.parse(date_string) }
    specify {
      parsed_date.should == nil
    }
  end

  context "reverse date" do
    let(:date_string) { "2014/09/22" }

    subject(:parsed_date) { DateParser.parse(date_string) }
    specify {
      parsed_date.year.should == 2014
      parsed_date.month.should == 9
      parsed_date.day.should == 22
    }
  end

end

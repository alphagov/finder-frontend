require 'spec_helper'

describe DateTimeHelper do

  describe "#formatted_date_html" do

    let(:datetime) { Time.zone.parse('01-01-2014 06:00:00') }
    subject { helper.formatted_date_html(datetime) }

    it "contains the iso formatted date or time" do
      expect(subject).to match("datetime=\"#{datetime.iso8601}\"")
    end

    it "should render the date as a as %d %B %Y" do
      expect(subject).to match("01 January 2014")
    end

    specify "given a time" do
      expect { subject }.to_not raise_error
    end

    context "given a date" do
      let(:datetime) { Date.parse('01-01-2014') }

      specify do
        expect { subject }.to_not raise_error
      end
    end

    context "given a string" do
      context "which is a time" do
        let(:datetime) { '01-01-2014 06:00:00' }

        specify do
          expect { subject }.to_not raise_error
        end
      end

      context "which is a date" do
        let(:datetime) { '01-01-2014' }

        specify do
          expect { subject }.to_not raise_error
        end
      end
    end
  end

end

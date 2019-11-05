require "spec_helper"

describe DateValidator do
  context "bad to_date params" do
    it "#error_hash" do
      bad_to_date =       { from: "01/01/01", to: "99/99/99" }
      error_hash =        { from: false, to: true }
      bad_to_date_query = double("query")
      validator = described_class.new(bad_to_date_query)

      allow(bad_to_date_query).to receive(:filter_params)
                              .and_return(public_timestamp: bad_to_date)

      expect(validator.error_hash).to eq(error_hash)
    end
  end

  context "bad from_date params" do
    it "#error_hash" do
      bad_from_date =       { from: "99/99/99", to: "01/01/01" }
      error_hash =          { from: true, to: false }
      bad_from_date_query = double("query")
      validator = described_class.new(bad_from_date_query)

      allow(bad_from_date_query).to receive(:filter_params)
                              .and_return(public_timestamp: bad_from_date)

      expect(validator.error_hash).to eq(error_hash)
    end
  end
end

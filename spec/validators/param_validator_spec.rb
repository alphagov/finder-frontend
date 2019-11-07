require "spec_helper"

describe ParamValidator do
  context "bad to_date params" do
    it "#errors_hash" do
      bad_to_date =       { from: "01/01/01", to: "99/99/99" }
      date_error_hash =   { public_timestamp: { from: false, to: true } }
      bad_to_date_query = double("query")
      validator = described_class.new(bad_to_date_query)

      allow(bad_to_date_query).to receive(:filter_params)
                              .and_return(public_timestamp: bad_to_date)

      expect(validator.errors_hash).to eq(date_error_hash)
    end
  end

  context "bad from_date params" do
    it "#errors_hash" do
      bad_from_date =       { from: "99/99/99", to: "01/01/01" }
      date_error_hash =     { public_timestamp: { from: true, to: false } }
      bad_from_date_query = double("query")
      validator = described_class.new(bad_from_date_query)

      allow(bad_from_date_query).to receive(:filter_params)
                              .and_return(public_timestamp: bad_from_date)

      expect(validator.errors_hash).to eq(date_error_hash)
    end
  end
end

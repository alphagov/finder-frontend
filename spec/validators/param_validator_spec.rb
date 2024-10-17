require "spec_helper"

describe ParamValidator do
  subject(:validator) { described_class.new(query) }

  let(:query) { instance_double(Search::Query, filter_params: { public_timestamp: }) }

  describe "#errors_hash" do
    subject(:errors_hash) { validator.errors_hash }

    context "without a date" do
      let(:public_timestamp) { nil }

      it { is_expected.to eq(public_timestamp: { from: false, to: false }) }
    end

    context "with invalid dates" do
      let(:public_timestamp) { { from: "99/99/99", to: "99/99/99" } }

      it { is_expected.to eq(public_timestamp: { from: true, to: true }) }
    end
  end
end

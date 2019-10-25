require "spec_helper"

describe DateErrorsPresenter do
  let(:bad_to_date)   { { from: "01/01/01", to: "99/99/99" } }
  let(:bad_from_date) { { from: "99/99/99", to: "01/01/01" } }

  subject(:presenter_bad_to_date)   { described_class.new(bad_to_date) }
  subject(:presenter_bad_from_date) { described_class.new(bad_from_date) }

  it "#error_hash" do
    error_hash = { from: false, to: true }
    expect(presenter_bad_to_date.error_hash).to eq(error_hash)

    error_hash = { from: true, to: false }
    expect(presenter_bad_from_date.error_hash).to eq(error_hash)
  end

  it "#present" do
    error_message = "Please enter a valid date"
    expect(presenter_bad_from_date.present("99/99/99")).to eq(error_message)
    expect(presenter_bad_from_date.present("01/01/01")).to be nil
  end
end

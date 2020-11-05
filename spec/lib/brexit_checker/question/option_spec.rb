require "spec_helper"

RSpec.describe BrexitChecker::Question::Option do
  describe "factories" do
    it "has a valid default factory" do
      option = FactoryBot.build(:brexit_checker_option)
      expect(option.valid?).to be(true)
    end
  end

  describe "validations" do
    let(:option_missing_attributes) { FactoryBot.build(:brexit_checker_option, label: nil) }

    it "label can't be blank" do
      message = "Validation failed: Label can't be blank"
      expect { option_missing_attributes.valid? }.to raise_error(ActiveModel::ValidationError, message)
    end
  end

  describe ".load_all" do
    let(:value) { "nationality-uk" }
    let(:label) { "British" }
    let(:exclude_if) { "living-uk" }
    let(:options_yaml) do
      [
        {
          "value" => value,
          "label" => label,
          "exclude_if" => exclude_if,
        },
      ]
    end

    let(:options) { described_class.load_all(options_yaml) }

    it "builds an array of options from attributes in the yaml" do
      expect(options.first.value).to eq(value)
      expect(options.first.label).to eq(label)
      expect(options.first.exclude_if).to eq(exclude_if)
    end
  end
end

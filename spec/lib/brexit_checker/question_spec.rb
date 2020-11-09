require "spec_helper"

RSpec.describe BrexitChecker::Question do
  describe "factories" do
    it "has a valid default factory" do
      question = FactoryBot.build(:brexit_checker_question)
      expect(question.valid?).to be(true)
    end
  end

  describe "validations" do
    let(:question_missing_attributes) { FactoryBot.build(:brexit_checker_question, key: nil, text: nil) }
    let(:question_with_invalid_type) { FactoryBot.build(:brexit_checker_question, type: "bananarama") }
    let(:question_with_invalid_options) { FactoryBot.build(:brexit_checker_question, options: {}) }

    it "key and text can't be blank" do
      message = "Validation failed: Key can't be blank, Text can't be blank"
      expect { question_missing_attributes.valid? }.to raise_error(ActiveModel::ValidationError, message)
    end

    it "type must be single, single_wrapped, multiple of multiple_grouped" do
      message = "Validation failed: Type is not included in the list"
      expect { question_with_invalid_type.valid? }.to raise_error(ActiveModel::ValidationError, message)
    end

    it "options must be an array" do
      message = "Validation failed: Options is not an array"
      expect { question_with_invalid_options.valid? }.to raise_error(ActiveModel::ValidationError, message)
    end
  end

  describe "building a question from the yaml file" do
    let(:caption) { "About you and your family" }
    let(:type) { "single" }
    let(:options) do
      [
        {
          "value" => "nationality-uk",
          "label" => "British",
          "exclude_if" => "living-uk",
        },
      ]
    end
    let(:key) { "nationality" }
    let(:text) { "What nationality are you?" }

    let(:question_yaml) do
      {
        "caption" => caption,
        "type" => type,
        "options" => options,
        "key" => key,
        "text" => text,
      }
    end

    let(:question) { BrexitChecker::Question.load(question_yaml) }

    it ".load builds a question from attributes in the yaml" do
      expect(question.caption).to eq(caption)
      expect(question.type).to eq(type)
      expect(question.key).to eq(key)
      expect(question.text).to eq(text)
    end

    it "#options returns an array of option objects" do
      expect(question.options.first).to be_an_instance_of(BrexitChecker::Question::Option)
    end

    it "#options removes an option if the criteria matches the option's exclude_if value " do
      expect(question.options("living-uk")).to eq([])
    end
  end

  describe ".find_by_key" do
    let(:question) { FactoryBot.build(:brexit_checker_question) }
    let(:question2) { FactoryBot.build(:brexit_checker_question) }

    before :each do
      allow(described_class).to receive(:load_all).and_return([question, question2])
    end

    it "returns a group by key" do
      expect(described_class.find_by_key(question.key)).to eq question
    end
  end
end

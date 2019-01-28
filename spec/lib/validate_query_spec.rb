require "spec_helper"
require 'validate_query'
require_relative "../helpers/validation_query_helper"

describe ValidateQuery do
  include ValidateQueryHelper

  before :each do
    stub_valid_query
    stub_invalid_query
  end

  describe "#validate" do
    context "with valid params" do
      let(:query_params) {
        {
          'content_purpose_supergroup' => %w(news_and_communications),
          'organisations' => %w(stories),
          'people' => %w(harry-potter),
        }
      }

      subject { described_class.new(query_params) }

      it "returns nil" do
        expect(subject.validate).to eql(nil)
      end
    end

    context "with invalid params" do
      let(:query_params) {
        {
          'blah' => 'news',
          'invalid_param' => 'stories',
          'people' => 'harry-potter',
        }
      }
      subject { described_class.new(query_params) }

      it "returns an error message" do
        expect(subject.validate).to eql("\"blah\" is not a valid filter field")
      end
    end
  end
end

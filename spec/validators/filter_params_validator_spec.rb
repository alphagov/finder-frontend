require "spec_helper"

describe FilterParamsValidator do
  describe "#validate" do
    it "raises an error if the keyword params is not a string" do
      params = HashWithIndifferentAccess.new("keywords" => %w[some keywords])
      expect {
        described_class.new(params).validate!
      }.to raise_error(ActionController::BadRequest, "Invalid 'keywords' query parameter")
    end
  end
end

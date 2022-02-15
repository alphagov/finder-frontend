require "spec_helper"
require "json"

describe "Healthcheck" do
  context "when everything is fine", type: :request do
    it "returns an OK status" do
      get "/healthcheck/ready"
      expect(JSON.parse(response.body)).to eq("status" => "ok")
    end
  end
end
